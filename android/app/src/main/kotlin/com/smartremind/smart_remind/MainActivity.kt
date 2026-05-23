package com.smartremind.smart_remind

import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.smartremind.smart_remind.services.AppMonitorService
import com.smartremind.smart_remind.utils.PermissionHelper

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.smartremind/app_alert"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    val permissions = mapOf(
                        "usageStats" to PermissionHelper.hasUsageStatsPermission(this),
                        "overlay" to PermissionHelper.hasOverlayPermission(this)
                    )
                    result.success(permissions)
                }
                "requestAuthorization" -> {
                    if (!PermissionHelper.hasUsageStatsPermission(this)) {
                        PermissionHelper.requestUsageStatsPermission(this)
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    if (!PermissionHelper.hasOverlayPermission(this)) {
                        PermissionHelper.requestOverlayPermission(this)
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    result.success(true)
                }
                "getSettings" -> {
                    val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, Context.MODE_PRIVATE)
                    result.success(
                        mapOf(
                            "alertsEnabled" to prefs.getBoolean("alerts_enabled", false),
                            "snoozeDuration" to prefs.getInt("snooze_duration", 15),
                        )
                    )
                }
                "setSnoozeDuration" -> {
                    val minutes = call.argument<Int>("minutes") ?: 15
                    val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().putInt("snooze_duration", minutes).apply()
                    result.success(null)
                }
                "startMonitoring" -> {
                    val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().putBoolean("alerts_enabled", true).apply()
                    
                    val serviceIntent = Intent(this, AppMonitorService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(null)
                }
                "stopMonitoring" -> {
                    val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().putBoolean("alerts_enabled", false).apply()
                    
                    val serviceIntent = Intent(this, AppMonitorService::class.java)
                    stopService(serviceIntent)
                    result.success(null)
                }
                "syncTaskData" -> {
                    val pendingCount = call.argument<Int>("pendingCount") ?: 0
                    val topCategory = call.argument<String>("topCategory") ?: "Inbox"
                    
                    val prefs = getSharedPreferences(AppMonitorService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putInt("pending_count", pendingCount)
                        .putString("top_category", topCategory)
                        .apply()
                        
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
