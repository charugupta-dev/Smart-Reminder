package com.smartremind.smart_remind.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.smartremind.smart_remind.services.AppMonitorService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs = context.getSharedPreferences(AppMonitorService.PREFS_NAME, Context.MODE_PRIVATE)
            val alertsEnabled = prefs.getBoolean("alerts_enabled", false)
            if (alertsEnabled) {
                val serviceIntent = Intent(context, AppMonitorService::class.java)
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            }
        }
    }
}
