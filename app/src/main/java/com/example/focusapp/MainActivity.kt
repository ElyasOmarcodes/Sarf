package com.example.focusapp

import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.focusapp.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val PREFS_NAME = "FocusAppPrefs"
    private val KEY_WHITELIST = "whitelist"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        updateWhitelistView()

        binding.btnAddNumber.setOnClickListener {
            val number = binding.etPhoneNumber.text.toString().trim()
            if (number.isNotEmpty()) {
                addNumberToWhitelist(number)
                binding.etPhoneNumber.text?.clear()
                updateWhitelistView()
            } else {
                Toast.makeText(this, "Please enter a valid number", Toast.LENGTH_SHORT).show()
            }
        }

        binding.btnPermissionCall.setOnClickListener {
            requestCallScreeningRole()
        }

        binding.btnPermissionAccessibility.setOnClickListener {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
        }
    }

    private fun addNumberToWhitelist(number: String) {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentList = prefs.getStringSet(KEY_WHITELIST, mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        currentList.add(number)
        prefs.edit().putStringSet(KEY_WHITELIST, currentList).apply()
        Toast.makeText(this, "Number added to whitelist", Toast.LENGTH_SHORT).show()
    }

    private fun updateWhitelistView() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentList = prefs.getStringSet(KEY_WHITELIST, setOf()) ?: setOf()
        if (currentList.isEmpty()) {
            binding.tvWhitelist.text = "No numbers added yet."
        } else {
            binding.tvWhitelist.text = currentList.joinToString("\n")
        }
    }

    private fun requestCallScreeningRole() {
        val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
        if (roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
            if (roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)) {
                Toast.makeText(this, "App is already the Call Screening App", Toast.LENGTH_SHORT).show()
            } else {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                startActivityForResult(intent, 1)
            }
        } else {
            Toast.makeText(this, "Call Screening Role not available", Toast.LENGTH_SHORT).show()
        }
    }
}
