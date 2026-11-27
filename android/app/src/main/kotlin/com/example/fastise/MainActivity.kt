package com.example.fastise

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.fastise/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args != null) {
                            saveWidgetSnapshot(args)
                            FastiseWidgetProvider.updateAllWidgets(applicationContext)
                        }
                        result.success(null)
                    }
                    "requestPinWidget" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val manager = AppWidgetManager.getInstance(applicationContext)
                            if (manager.isRequestPinAppWidgetSupported) {
                                val provider = ComponentName(
                                    applicationContext,
                                    FastiseWidgetProvider::class.java
                                )
                                val requested = manager.requestPinAppWidget(provider, null, null)
                                result.success(requested)
                            } else {
                                result.success(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveWidgetSnapshot(args: Map<*, *>) {
        val prefs = applicationContext.getSharedPreferences(
            FastiseWidgetProvider.PREFS_NAME,
            Context.MODE_PRIVATE
        )
        prefs.edit().apply {
            putString("mood", args["mood"] as? String ?: "idle")
            putString("headline", args["headline"] as? String ?: "Ready to fast?")
            putString("subtext", args["subtext"] as? String ?: "16:8 · 16 h goal")
            putString("actionLabel", args["actionLabel"] as? String ?: "Start Fast")
            putString("planName", args["planName"] as? String ?: "16:8")
            putInt("fastingHours", (args["fastingHours"] as? Number)?.toInt() ?: 16)
            putInt("streakDays", (args["streakDays"] as? Number)?.toInt() ?: 0)
            putLong("startAtEpochMs", (args["startAtEpochMs"] as? Number)?.toLong() ?: 0L)
            putLong("targetEndEpochMs", (args["targetEndEpochMs"] as? Number)?.toLong() ?: 0L)
            putInt("progressPercent", (args["progressPercent"] as? Number)?.toInt() ?: 0)
            putString("lastDurationLabel", args["lastDurationLabel"] as? String ?: "")
            apply()
        }
    }
}
