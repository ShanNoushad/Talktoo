import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:talk_in/custom/ringtone/ringtone_method.dart';
import 'package:talk_in/localization/locale_constant.dart';
import 'package:talk_in/routes/app_pages.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/services/notification_service/notification_services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'localization/localizations_delegate.dart';
import 'utils/utils.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

AppLifecycleState? currentAppLifecycleState;

Future<void> syncFcmTokenToBackend(String token) async {
  try {
    if (Database.loginUserId.isEmpty) return;

    final response = await http.post(
      Uri.parse(Api.updateFcmToken),
      headers: {
        'Content-Type': 'application/json',
        'key': Api.secretKey,
        'x-auth-token': 'Bearer ${Api.secretKey}',
        'x-auth-uid': Database.loginUserId,
      },
      body: jsonEncode({'fcmToken': token}),
    );

    Utils.showLog('FCM sync response: ${response.statusCode} ${response.body}');
  } catch (e) {
    Utils.showLog('FCM token sync failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await 500.milliseconds.delay();

  if (Platform.isAndroid) {
    await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
  }

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(backgroundNotification);

  await GetStorage.init();
  WakelockPlus.enable();
  await RingtoneService.init();

  final identity = (await MobileDeviceIdentifier().getDeviceId())!;
  final fcmToken = await FirebaseMessaging.instance.getToken();

  Utils.showLog("Device Id => $identity");
  Utils.showLog("FCM Token => $fcmToken");

  if (fcmToken != null) {
    await Database.init(identity, fcmToken);
    await syncFcmTokenToBackend(fcmToken);
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    Utils.showLog('FCM Token refreshed => $newToken');
    Database.onSetFcmToken(newToken);
    await syncFcmTokenToBackend(newToken);
  });

  await NotificationServices.init();
  NotificationServices.firebaseInit();
  await PermissionHandler.notificationPermissions();
  await PermissionHandler.cameraPermissions();
  await PermissionHandler.microphonePermissions();
  await PermissionHandler.storagePermissions();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final StreamController purchaseStreamController =
  StreamController<PurchaseDetails>.broadcast();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    currentAppLifecycleState = state;
    Utils.showLog('AppLifecycleState changed to: $state');
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        log("didChangeDependencies Preference Revoked ${locale.languageCode}");
        log("didChangeDependencies GET LOCALE Revoked ${Get.locale?.languageCode}");
        Get.updateLocale(locale);
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Utils.showLog("MY Current Routes => ${Get.currentRoute}");
    return GetMaterialApp(
      title: 'TalkToo App',
      debugShowCheckedModeBanner: false,
      locale: const Locale("en"),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Container(
            color: AppColors.black,
            child: SafeArea(
              bottom: true,
              top: false,
              left: false,
              right: false,
              child: Scaffold(
                backgroundColor: AppColors.black,
                body: Stack(
                  children: [
                    child ?? const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      translations: AppLanguages(),
      initialRoute: AppRoutes.splashScreenPage,
      getPages: AppPages.list,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}