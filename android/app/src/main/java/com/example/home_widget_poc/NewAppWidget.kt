package com.example.home_widget_poc

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.ComponentName
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews

import android.util.Log

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Implementation of App Widget functionality.
 */
class NewAppWidget : AppWidgetProvider() {

    companion object {
        private const val ACTION_TOGGLE_VISIBILITY = "com.example.home_widget_poc.TOGGLE_VISIBILITY"
        private const val ACTION_UPDATE_TIMER = "com.example.home_widget_poc.UPDATE_TIMER"
        private var isVisible = false
        private const val CHANNEL = "com.example.home_widget_poc/channel"
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        Log.d("NewAppWidget", "Intent: ${intent.action}")

        when (intent.action){
            ACTION_TOGGLE_VISIBILITY -> {
                isVisible = !isVisible  // Cambia la visibilidad

                if (isVisible){
                    val flutterEngine = FlutterEngine(context)
                    flutterEngine.dartExecutor.executeDartEntrypoint(
                        DartExecutor.DartEntrypoint.createDefault()
                    )

                    val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

                    // 🔥 Llamar a Flutter para obtener el nuevo texto
                    channel.invokeMethod("fetchSecretText", null, object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            val data = result as? Map<*, *> ?: return
                            val secretText = data["code"] as? String ?: "******"
                            val countdownValue = (data["time"] as? Int) ?: 60
                            Log.d("NewAppWidget", "✅ Code recibido desde Flutter: $secretText")
                            Log.d("NewAppWidget", "✅ Time recibido desde Flutter: $countdownValue")

                            val prefs = context.getSharedPreferences("TimerPrefs", Context.MODE_PRIVATE)
                            prefs.edit()
                                .putString("secret_text", secretText)
                                .putInt("countdown_value", countdownValue)
                                .putLong("end_time", System.currentTimeMillis() + countdownValue * 1000)
                                .apply()

                            // 🔥 Actualizar el widget con el nuevo texto
                            updateAppWidget(context, AppWidgetManager.getInstance(context))
                        }

                        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            Log.e("NewAppWidget", "❌ Error en Flutter: $errorMessage")
                        }

                        override fun notImplemented() {
                            Log.e("NewAppWidget", "❌ Método no implementado en Flutter")
                        }
                    })
                }else {
                    updateAppWidget(context, AppWidgetManager.getInstance(context))
                }
            }

            ACTION_UPDATE_TIMER -> {
                Log.d("NewAppWidget", "⏳ Temporizador actualizado")
                updateAppWidget(context, AppWidgetManager.getInstance(context))
            }
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager) {
        val views = RemoteViews(context.packageName, R.layout.new_app_widget2)
        Log.d("NewAppWidget", "Ingrese a UpdateAppWidget")

        val prefs = context.getSharedPreferences("TimerPrefs", Context.MODE_PRIVATE)

        val secretText = prefs.getString("secret_text", "******") ?: "******"
        val countdownValue = prefs.getInt("countdown_value", 0)
        val endTime = prefs.getLong("end_time", 0)

        val timeLeft = if (endTime > System.currentTimeMillis()) endTime - System.currentTimeMillis() else 0

        Log.d("NewAppWidget", "EndTime: $endTime")
        Log.d("NewAppWidget", "TimeLeft: $timeLeft")

        val progress = if (timeLeft > 0) {
            100 - ((timeLeft.toFloat() / (60 * 1000)) * 100).toInt()
        } else 0

        val textToShow = if (isVisible) secretText ?: "******" else "******"

        if (timeLeft <= 0) {
            Log.d("NewAppWidget", "SE ACABOOOOO!!")
            prefs.edit()
                .remove("secret_text")
                .remove("countdown_value")
                .remove("end_time")
                .apply()

            views.setTextViewText(R.id.text_secret, "******")
            views.setProgressBar(R.id.progress_timer, 100, 0, false)
        }else{
            views.setTextViewText(R.id.text_secret, textToShow)
            views.setProgressBar(R.id.progress_timer, 100, progress, false)

            scheduleNextUpdate(context)
        }

        Log.d("NewAppWidget", "📢 Clave: $textToShow Progreso: $progress%")

        Log.d("NewAppWidget", "Texto a mostrar: $textToShow")

        // Intent para alternar visibilidad
        val intent = Intent(context, NewAppWidget::class.java).apply {
            action = ACTION_TOGGLE_VISIBILITY
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )

        views.setOnClickPendingIntent(R.id.btn_visibility, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetManager.getAppWidgetIds(ComponentName(context, NewAppWidget::class.java)), views)
    }

    private fun scheduleNextUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, NewAppWidget::class.java).apply {
            action = ACTION_UPDATE_TIMER
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )

        if (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                alarmManager.canScheduleExactAlarms()
            } else {
                false
            }
        ) {
            Log.d("NewAppWidget", "✅ Se tiene permiso para alarmas exactas, programando actualización.")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S){
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    SystemClock.elapsedRealtime() + 1000,
                    pendingIntent
                )
            }
        } else {
            Log.e("NewAppWidget", "❌ No se tiene permiso para alarmas exactas.")
        }
    }
}


