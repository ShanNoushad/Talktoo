//package com.incodes.talktoo
//
//import io.flutter.embedding.android.FlutterFragmentActivity
//
//class MainActivity: FlutterFragmentActivity()


package com.stellarplace.live

import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "ringtone_channel"
    private var ringtone: Ringtone? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playRingtone" -> {
                    try {
                        val notification: Uri = RingtoneManager.getDefaultUri(
                            RingtoneManager.TYPE_RINGTONE
                        )
                        ringtone = RingtoneManager.getRingtone(
                            applicationContext,
                            notification
                        )
                        ringtone?.play()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("RINGTONE_ERROR", e.message, null)
                    }
                }
                "stopRingtone" -> {
                    try {
                        ringtone?.stop()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("RINGTONE_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        ringtone?.stop()
        super.onDestroy()
    }
}
