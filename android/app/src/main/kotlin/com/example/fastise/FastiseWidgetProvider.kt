package com.example.fastise

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews

class FastiseWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            updateAppWidget(context, appWidgetManager, appWidgetId, options)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        updateAppWidget(context, appWidgetManager, appWidgetId, newOptions)
    }

    companion object {
        const val PREFS_NAME = "fastise_widget_prefs"
        private const val WIDE_THRESHOLD_DP = 210

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, FastiseWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            for (id in ids) {
                val options = manager.getAppWidgetOptions(id)
                updateAppWidget(context, manager, id, options)
            }
        }

        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            options: Bundle?
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            var mood = prefs.getString("mood", "idle") ?: "idle"
            var headline = prefs.getString("headline", "Ready to fast?") ?: "Ready to fast?"
            var subtext = prefs.getString("subtext", "16:8 · 16 h goal") ?: "16:8 · 16 h goal"
            var actionLabel = prefs.getString("actionLabel", "Start Fast") ?: "Start Fast"
            val streakDays = prefs.getInt("streakDays", 0)
            val startAtEpochMs = prefs.getLong("startAtEpochMs", 0L)
            val targetEndEpochMs = prefs.getLong("targetEndEpochMs", 0L)
            var progressPercent = prefs.getInt("progressPercent", 0)

            // Re-evaluate live fasting goal state in case target time elapsed while app was closed.
            val nowMs = System.currentTimeMillis()
            if ((mood == "fasting" || mood == "target_reached") && startAtEpochMs > 0L) {
                val totalPlanned = maxOf(1L, targetEndEpochMs - startAtEpochMs)
                val elapsed = maxOf(0L, nowMs - startAtEpochMs)
                progressPercent = ((elapsed * 100L) / totalPlanned).toInt().coerceIn(0, 100)
                if (targetEndEpochMs > 0L && nowMs >= targetEndEpochMs) {
                    mood = "target_reached"
                    headline = "Goal reached!"
                    subtext = "End whenever you feel ready"
                    actionLabel = "Wrap Up"
                }
            }

            val minWidthDp = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) ?: 250
            val isWide = minWidthDp >= WIDE_THRESHOLD_DP
            val layoutId = if (isWide) {
                R.layout.fastise_widget_wide
            } else {
                R.layout.fastise_widget_compact
            }
            val views = RemoteViews(context.packageName, layoutId)

            val bgRes = when (mood) {
                "fasting" -> R.drawable.widget_bg_sage
                "target_reached" -> R.drawable.widget_bg_warm
                else -> R.drawable.widget_bg_obsidian
            }
            val mascotRes = when (mood) {
                "fasting" -> R.drawable.ic_mascot_fasting
                "target_reached" -> R.drawable.ic_mascot_goal
                "done_today" -> R.drawable.ic_mascot_done
                else -> R.drawable.ic_mascot_idle
            }
            val streakLabel = if (streakDays <= 0) {
                "Start Day 1"
            } else {
                "$streakDays day streak"
            }

            views.setInt(R.id.widget_root, "setBackgroundResource", bgRes)
            views.setImageViewResource(R.id.widget_mascot, mascotRes)
            views.setTextViewText(R.id.widget_streak_text, streakLabel)
            views.setTextViewText(R.id.widget_headline, headline)
            views.setTextViewText(R.id.widget_subtext, subtext)

            val isActive = (mood == "fasting" || mood == "target_reached") && startAtEpochMs > 0L
            if (isActive) {
                val elapsedMs = maxOf(0L, nowMs - startAtEpochMs)
                val baseTime = SystemClock.elapsedRealtime() - elapsedMs
                views.setViewVisibility(R.id.widget_chronometer, View.VISIBLE)
                views.setChronometer(R.id.widget_chronometer, baseTime, null, true)
                views.setTextColor(
                    R.id.widget_chronometer,
                    if (mood == "target_reached") Color.parseColor("#D9B382") else Color.parseColor("#82D4B2")
                )
            } else {
                views.setChronometer(R.id.widget_chronometer, SystemClock.elapsedRealtime(), null, false)
                views.setViewVisibility(R.id.widget_chronometer, View.GONE)
            }

            if (isWide) {
                views.setTextViewText(R.id.widget_action_pill, actionLabel)
                views.setInt(
                    R.id.widget_action_pill,
                    "setBackgroundResource",
                    if (mood == "target_reached") R.drawable.widget_pill_warm else R.drawable.widget_pill_sage
                )
                if (isActive) {
                    views.setViewVisibility(R.id.widget_progress, View.VISIBLE)
                    views.setProgressBar(R.id.widget_progress, 100, progressPercent, false)
                } else {
                    views.setViewVisibility(R.id.widget_progress, View.GONE)
                }
            }

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingFlags = PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
            val pendingIntent = PendingIntent.getActivity(context, 0, launchIntent, pendingFlags)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
