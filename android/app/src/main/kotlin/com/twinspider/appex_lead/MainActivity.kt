package com.twinspider.appex_lead

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.content.Intent

class MainActivity : FlutterActivity(){
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = "appex_lead_channel"

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceModel" -> {
                    val model = Build.MODEL
                    result.success(model)
                }
                "startTrackingService" -> {
                    val routeId = call.argument<Long>("route_id") ?: -1L
                    val intent = Intent(this, LocationTrackingService::class.java).apply {
                        putExtra("route_id", routeId)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(true)
                }
                "stopTrackingService" -> {
                    val intent = Intent(this, LocationTrackingService::class.java)
                    stopService(intent)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
