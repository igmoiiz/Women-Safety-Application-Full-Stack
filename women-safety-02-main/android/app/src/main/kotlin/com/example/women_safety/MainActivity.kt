package com.example.women_safety

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "battery_optimization_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        val payload = intent.getStringExtra("payload")
        if (payload == "whatsapp") {
            launchWhatsAppActivity()
        }
    }

    private fun launchWhatsAppActivity() {
        val redirectIntent = Intent(this, WhatsAppRedirectActivity::class.java)
        redirectIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(redirectIntent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(
            BatteryOptimizationHandler(context)
        )
    }
}