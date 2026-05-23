package com.smartremind.smart_remind.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.core.app.NotificationCompat
import com.smartremind.smart_remind.R
import com.smartremind.smart_remind.utils.MonitoredAppsConfig

class AppMonitorService : Service() {

    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var prefs: SharedPreferences
    
    // Polling interval in ms
    private val POLL_INTERVAL = 3000L 
    
    // Session tracking
    private var lastForegroundPackage: String = ""
    private var isOverlayAttached = false
    private var activeMonitoredPackage: String? = null

    companion object {
        const val CHANNEL_ID = "SmartRemindMonitorChannel"
        const val PREFS_NAME = "SmartRemindAppAlerts"
        fun snoozeKey(packageName: String): String = "snooze_$packageName"
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildForegroundNotification()
        startForeground(1001, notification)
        
        // Start polling loop
        handler.removeCallbacksAndMessages(null)
        handler.post(pollTask)
        
        return START_STICKY
    }

    private val pollTask = object : Runnable {
        override fun run() {
            checkForegroundApp()
            handler.postDelayed(this, POLL_INTERVAL)
        }
    }

    private fun checkForegroundApp() {
        if (!prefs.getBoolean("alerts_enabled", false)) {
            lastForegroundPackage = ""
            removeOverlay()
            return
        }

        val pendingCount = prefs.getInt("pending_count", 0)
        if (pendingCount <= 0) {
            lastForegroundPackage = ""
            removeOverlay()
            return
        }

        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            now - 1000 * 60, now
        )
        
        val currentForegroundPackage = stats?.maxByOrNull { it.lastTimeUsed }?.packageName ?: ""

        if (currentForegroundPackage.isBlank()) {
            lastForegroundPackage = ""
            removeOverlay()
            return
        }

        val appChanged = currentForegroundPackage != lastForegroundPackage
        lastForegroundPackage = currentForegroundPackage

        if (!MonitoredAppsConfig.isMonitored(currentForegroundPackage)) {
            removeOverlay()
            return
        }

        val snoozeExpiry = prefs.getLong(snoozeKey(currentForegroundPackage), 0L)
        if (System.currentTimeMillis() < snoozeExpiry) {
            removeOverlay()
            return
        }

        if (appChanged || !isOverlayAttached || activeMonitoredPackage != currentForegroundPackage) {
            activeMonitoredPackage = currentForegroundPackage
            showOverlay()
        }
    }

    private fun showOverlay() {
        if (isOverlayAttached) {
            removeOverlay()
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) 
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY 
            else 
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.layout_shield_overlay, null)
        
        val pendingCount = prefs.getInt("pending_count", 0)
        val topCategory = prefs.getString("top_category", "Inbox") ?: "Inbox"
        val snoozeMins = prefs.getInt("snooze_duration", 15)

        overlayView?.findViewById<TextView>(R.id.text_subtitle)?.text = 
            "You have $pendingCount items in '$topCategory'."
            
        overlayView?.findViewById<Button>(R.id.btn_skip)?.text = "Skip for $snoozeMins mins"

        overlayView?.findViewById<Button>(R.id.btn_open_app)?.setOnClickListener {
            openApp()
            removeOverlay()
        }

        overlayView?.findViewById<Button>(R.id.btn_skip)?.setOnClickListener {
            snoozeApp(snoozeMins)
            removeOverlay()
        }

        windowManager.addView(overlayView, params)
        isOverlayAttached = true
    }

    private fun removeOverlay() {
        if (isOverlayAttached && overlayView != null) {
            windowManager.removeView(overlayView)
            isOverlayAttached = false
            activeMonitoredPackage = null
            overlayView = null
        }
    }

    private fun openApp() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        if (launchIntent != null) {
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            startActivity(launchIntent)
        }
    }

    private fun snoozeApp(snoozeMins: Int) {
        val pkg = activeMonitoredPackage ?: return
        val expiryTime = System.currentTimeMillis() + (snoozeMins * 60 * 1000L)
        prefs.edit().putLong(snoozeKey(pkg), expiryTime).apply()
        
        // Un-snooze via AlarmManager isn't strictly necessary since we check expiry in loop,
        // but it can be used to wake up or send a notification if desired. We use passive verification here.
    }

    private fun buildForegroundNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SmartRemind App Alerts")
            .setContentText("Monitoring app usage to help you stay on task")
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Fallback icon
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "App Usage Monitor",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Runs background checks to show task reminders"
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        removeOverlay()
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
