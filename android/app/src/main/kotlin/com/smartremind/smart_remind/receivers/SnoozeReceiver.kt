package com.smartremind.smart_remind.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.smartremind.smart_remind.services.AppMonitorService

class SnoozeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val packageName = intent.getStringExtra("packageName")
        if (packageName != null) {
            val prefs = context.getSharedPreferences(AppMonitorService.PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putLong(AppMonitorService.snoozeKey(packageName), 0L).apply()
        }
    }
}
