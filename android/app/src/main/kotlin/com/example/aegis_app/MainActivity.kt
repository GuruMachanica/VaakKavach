package com.example.aegis_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val nativeAudioEngine = AegisNativeAudioEngine()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register MethodChannel for command invocations
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.aegis_app/native_audio"
        ).setMethodCallHandler(nativeAudioEngine)

        // Register EventChannel for real-time acoustic telemetry streaming
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.aegis_app/audio_stream"
        ).setStreamHandler(nativeAudioEngine)

        // Register MethodChannel for direct autonomous guardian SOS SMS
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.aegis_app/native_sms"
        ).setMethodCallHandler { call, result ->
            if (call.method == "sendDirectSms") {
                val phone = call.argument<String>("phone")
                val message = call.argument<String>("message")
                if (!phone.isNullOrBlank() && !message.isNullOrBlank()) {
                    try {
                        @Suppress("DEPRECATION")
                        val smsManager = android.telephony.SmsManager.getDefault()
                        val parts = smsManager.divideMessage(message)
                        smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                } else {
                    result.error("INVALID_ARGS", "Phone and message required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        nativeAudioEngine.stopRecording()
        super.onDestroy()
    }
}
