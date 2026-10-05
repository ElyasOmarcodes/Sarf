package com.example.focusapp

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppBlockerService : AccessibilityService() {

    // List of social media and distraction apps to block
    private val blockedPackages = listOf(
        "com.whatsapp",
        "com.facebook.katana",
        "com.instagram.android",
        "com.twitter.android",
        "com.zhiliaoapp.musically", // TikTok
        "com.snapchat.android"
    )

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            Log.d("AppBlockerService", "Window state changed for package: $packageName")

            if (packageName != null && blockedPackages.contains(packageName)) {
                Log.d("AppBlockerService", "Blocking app: $packageName")
                blockApp()
            }
        }
    }

    private fun blockApp() {
        val intent = Intent(this, AppBlockedActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        startActivity(intent)
    }

    override fun onInterrupt() {
        // Required method for AccessibilityService
    }
}
