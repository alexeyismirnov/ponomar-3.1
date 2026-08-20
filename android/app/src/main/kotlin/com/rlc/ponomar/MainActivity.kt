package com.rlc.ponomar

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "moveToBack" -> {
                        moveTaskToBack(true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        private const val CHANNEL = "com.rlc.ponomar/android"
    }
}
