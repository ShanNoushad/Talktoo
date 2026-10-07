import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/ui/user_flow/calling_screen/controller/calling_screen_controller.dart';
import 'package:talk_in/ui/user_flow/calling_screen/shimmer/calling_history_shimmer.dart';
import 'package:talk_in/ui/user_flow/calling_screen/widget/calling_screen_widget.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/controller/coin_history_screen_controller.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/model/coin_history_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';

class CallingScreen extends StatelessWidget {
  const CallingScreen({super.key});

  // Call-related transaction types inside CoinHistory:
  // 3 = Private Audio Call, 4 = Private Video Call,
  // 5 = Random Audio Call,  6 = Random Video Call
  static const List<int> _callTypes = [3, 4, 5, 6];

  String _callStatusTextFor(CoinHistory item) {
    // CoinHistory has no missed/incoming/outgoing flag, so we fall back to a
    // label derived from the transaction type instead.
    switch (item.type) {
      case 3:
        return "Private Audio Call";
      case 4:
        return "Private Video Call";
      case 5:
        return "Random Audio Call";
      case 6:
        return "Random Video Call";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const CallingScreenAppBar(),
      ),
      body: GetBuilder<CoinHistoryScreenController>(
        init: Get.isRegistered<CoinHistoryScreenController>() ? null : CoinHistoryScreenController(),
        id: Constant.idTabChange,
        builder: (controller) {
          final callEntries = controller.coinHistoryList.where((e) => _callTypes.contains(e.type)).toList();

          return controller.isLoading
              ? CallingHistoryShimmer().paddingSymmetric(horizontal: 14, vertical: 12)
              : callEntries.isEmpty
              ? Center(
            child: Image.asset(
              AppAsset.noHistoryFound,
              height: 300,
            ).paddingAll(90),
          )
              : RefreshIndicator(
            onRefresh: () async => controller.onRefresh(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: controller.scrollController,
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: callEntries.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Important!
                    itemBuilder: (context, index) {
                      final item = callEntries[index];
                      return CallingScreenItem(
                        // CoinHistory carries no availability/rate/listener-id
                        // data, so the call action always shows its disabled
                        // ("Listener is not available") state here. audioCall
                        // and videoCall are false, so CallingScreenItem never
                        // actually reads from `controller` below — it's only
                        // passed to satisfy the widget's required parameter.
                        audioCall: false,
                        videoCall: false,
                        controller: Get.isRegistered<CallingScreenController>() ? Get.find<CallingScreenController>() : Get.put(CallingScreenController()),
                        time: item.date.toString(),
                        callStatusText: _callStatusTextFor(item),
                        coin: item.userCoin ?? 0,
                        duration: item.duration,
                        name: item.receiverName.toString(),
                        image: item.receiverImage.toString(),
                        index: index,
                      ).paddingOnly(bottom: 12, top: index == 0 ? 12 : 0);
                    },
                  ),
                  GetBuilder<CoinHistoryScreenController>(
                    id: Constant.idPaginationListener,
                    builder: (controller) => Visibility(
                      visible: controller.isPaginationLoading,
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}