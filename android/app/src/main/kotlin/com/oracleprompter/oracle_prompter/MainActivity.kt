package com.oracleprompter.oracle_prompter

import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.oracleprompter/session"
    private val TAG = "O.P"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startSession" -> {
                        Log.i(TAG, "Starting O.P session service")
                        startSession()
                        result.success(true)
                    }
                    "stopSession" -> {
                        Log.i(TAG, "Stopping O.P session service")
                        stopSession()
                        result.success(true)
                    }
                    "isSessionRunning" -> {
                        result.success(OPSessionService.isRunning)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startSession() {
        val intent = Intent(this, OPSessionService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopSession() {
        val intent = Intent(this, OPSessionService::class.java)
        intent.action = "STOP_SERVICE"
        startService(intent)
    }
}
