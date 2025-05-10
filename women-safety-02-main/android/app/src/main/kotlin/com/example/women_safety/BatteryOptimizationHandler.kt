package com.example.women_safety

import android.content.Context
import android.os.Build
import android.os.PowerManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.content.Intent
import android.net.Uri
import android.os.Build.MANUFACTURER
import android.content.ComponentName

class BatteryOptimizationHandler(private val context: Context) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isIgnoringBatteryOptimization" -> {
                val packageName = call.argument<String>("packageName") ?: context.packageName
                val isIgnoring = isIgnoringBatteryOptimization(packageName)
                result.success(isIgnoring)
            }
            "requestManufacturerSpecificSettings" -> {
                val success = requestManufacturerSpecificSettings()
                result.success(success)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun isIgnoringBatteryOptimization(packageName: String): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            return powerManager.isIgnoringBatteryOptimizations(packageName)
        }
        return true // Before Android M, no battery optimization existed
    }

    private fun requestManufacturerSpecificSettings(): Boolean {
        try {
            when (MANUFACTURER.toLowerCase()) {
                "xiaomi", "redmi" -> openXiaomiSettings()
                "huawei", "honor" -> openHuaweiSettings()
                "samsung" -> openSamsungSettings()
                "oneplus" -> openOnePlusSettings()
                "oppo" -> openOppoSettings()
                "vivo" -> openVivoSettings()
                else -> return false // Unknown manufacturer
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun openXiaomiSettings() {
        try {
            val intent = Intent()
            intent.component = ComponentName(
                "com.miui.powerkeeper",
                "com.miui.powerkeeper.ui.HiddenAppsConfigActivity"
            )
            intent.putExtra("package_name", context.packageName)
            intent.putExtra("package_label", getApplicationName())
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (e: Exception) {
            // Fallback for newer MIUI versions
            try {
                val intent = Intent()
                intent.component = ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity"
                )
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
    }

    private fun openHuaweiSettings() {
        try {
            val intent = Intent()
            intent.component = ComponentName(
                "com.huawei.systemmanager",
                "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun openSamsungSettings() {
        try {
            val intent = Intent()
            intent.component = ComponentName(
                "com.samsung.android.lool",
                "com.samsung.android.sm.ui.battery.BatteryActivity"
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun openOnePlusSettings() {
        try {
            val intent = Intent()
            intent.component = ComponentName(
                "com.oneplus.security",
                "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun openOppoSettings() {
        try {
            val intent = Intent()
            intent.component = ComponentName(
                "com.coloros.safecenter",
                "com.coloros.safecenter.permission.startup.StartupAppListActivity"
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun openVivoSettings() {
        try {
            val intent = Intent()
            intent.component = ComponentName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun getApplicationName(): String {
        val applicationInfo = context.applicationInfo
        val stringId = applicationInfo.labelRes
        return if (stringId == 0) applicationInfo.nonLocalizedLabel.toString() else context.getString(stringId)
    }
}
