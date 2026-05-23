package com.smartremind.smart_remind.utils

object MonitoredAppsConfig {
    val MONITORED_PACKAGES = mapOf(
        // Social Media
        "com.instagram.android" to "Social Media",
        "com.twitter.android" to "Social Media",
        "com.facebook.katana" to "Social Media",
        "com.snapchat.android" to "Social Media",
        "com.zhiliaoapp.musically" to "Social Media", // TikTok
        "com.reddit.frontpage" to "Social Media",
        "com.whatsapp" to "Social Media", // Often used socially
        "com.linkedin.android" to "Social Media",
        "org.telegram.messenger" to "Social Media",
        
        // YouTube / Video
        "com.google.android.youtube" to "YouTube",
        "tv.twitch.android.app" to "YouTube",
        
        // OTT Platforms
        "com.netflix.mediaclient" to "OTT",
        "in.startv.hotstar" to "OTT",
        "com.amazon.avod.thirdpartyclient" to "OTT",  // Prime Video
        "com.jio.media.ondemand" to "OTT",  // JioCinema
        "com.sonyliv" to "OTT",
        "com.hbo.hbonow" to "OTT",
        "com.disney.disneyplus" to "OTT",

        // Add games commonly played here or allow users to add dynamically in future
        "com.kakaogames.twos" to "Games",
        "com.ea.game.pvz2_row" to "Games",
        "com.supercell.clashofclans" to "Games",
        "com.nianticlabs.pokemongo" to "Games",
        "com.mobile.legends" to "Games",
        "com.tencent.ig" to "Games", // PUBG
        "com.activision.callofduty.shooter" to "Games"
    )

    fun isMonitored(packageName: String?): Boolean {
        if (packageName == null) return false
        return MONITORED_PACKAGES.containsKey(packageName)
    }
}
