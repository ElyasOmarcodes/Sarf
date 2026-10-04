package com.example.focusapp

import android.content.Context
import android.net.Uri
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

class CallBlockerService : CallScreeningService() {

    private val PREFS_NAME = "FocusAppPrefs"
    private val KEY_WHITELIST = "whitelist"

    override fun onScreenCall(callDetails: Call.Details) {
        val handle: Uri? = callDetails.handle
        val phoneNumber = handle?.schemeSpecificPart ?: ""

        Log.d("CallBlockerService", "Incoming call from: $phoneNumber")

        if (callDetails.callDirection == Call.Details.DIRECTION_INCOMING) {
            val isWhitelisted = checkWhitelist(phoneNumber)

            if (isWhitelisted) {
                Log.d("CallBlockerService", "Number is whitelisted. Allowing call.")
                respondToCall(callDetails, CallResponse.Builder().build())
            } else {
                Log.d("CallBlockerService", "Number is NOT whitelisted. Rejecting call.")
                val response = CallResponse.Builder()
                    .setDisallowCall(true)
                    .setRejectCall(true)
                    .setSkipCallLog(false)
                    .setSkipNotification(true)
                    .build()
                respondToCall(callDetails, response)
            }
        }
    }

    private fun checkWhitelist(number: String): Boolean {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val whitelist = prefs.getStringSet(KEY_WHITELIST, setOf()) ?: setOf()

        // Very basic matching. In production you'd want to handle country codes, etc.
        // For simplicity we check if the stored string is a substring of the incoming number, or vice versa
        for (whitelistedNumber in whitelist) {
            val cleanStored = whitelistedNumber.replace(Regex("[^0-9+]"), "")
            val cleanIncoming = number.replace(Regex("[^0-9+]"), "")

            if (cleanIncoming.endsWith(cleanStored) || cleanStored.endsWith(cleanIncoming)) {
                return true
            }
        }
        return false
    }
}
