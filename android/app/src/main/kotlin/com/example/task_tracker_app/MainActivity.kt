package com.example.task_tracker_app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "task_tracker/external_apps"
    private val WIDGET_CHANNEL = "task_tracker/widgets"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup external apps method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setupQuickTile" -> {
                    setupQuickTile()
                    result.success(true)
                }
                "setupShortcuts" -> {
                    val shortcuts = call.argument<List<Map<String, Any>>>("shortcuts")
                    setupShortcuts(shortcuts)
                    result.success(true)
                }
                "shareText" -> {
                    val text = call.argument<String>("text")
                    shareText(text)
                    result.success(true)
                }
                "isAppInstalled" -> {
                    val packageName = call.argument<String>("package")
                    val isInstalled = isAppInstalled(packageName)
                    result.success(isInstalled)
                }
                else -> result.notImplemented()
            }
        }

        // Setup widgets method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    initializeWidgets()
                    result.success(true)
                }
                "updateWidget" -> {
                    val widgetType = call.argument<String>("widgetType")
                    val data = call.argument<Map<String, Any>>("data")
                    updateWidget(widgetType, data)
                    result.success(true)
                }
                "configureWidget" -> {
                    val widgetType = call.argument<String>("widgetType")
                    val settings = call.argument<Map<String, Any>>("settings")
                    configureWidget(widgetType, settings)
                    result.success(true)
                }
                "removeWidget" -> {
                    val widgetId = call.argument<String>("widgetId")
                    removeWidget(widgetId)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            when (it.action) {
                "CREATE_QUICK_TASK" -> {
                    // Handle quick task creation from shortcut
                    val title = it.getStringExtra("title") ?: "Quick Task"
                    handleShortcutAction("CREATE_QUICK_TASK", mapOf("title" to title))
                }
                "CREATE_VOICE_TASK" -> {
                    // Handle voice task creation from shortcut
                    handleShortcutAction("CREATE_VOICE_TASK", emptyMap())
                }
                "VIEW_TODAY_TASKS" -> {
                    // Handle view today's tasks from shortcut
                    handleShortcutAction("VIEW_TODAY_TASKS", emptyMap())
                }
            }
        }
    }

    private fun handleShortcutAction(action: String, data: Map<String, Any>) {
        // Send shortcut action to Flutter
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).invokeMethod("handleShortcut", mapOf(
                "action" to action,
                "data" to data
            ))
        }
    }

    private fun setupQuickTile() {
        // Quick tile setup is handled in the TileService class
        // This method can be used for any additional setup if needed
    }

    private fun setupShortcuts(shortcuts: List<Map<String, Any>>?) {
        shortcuts?.let {
            // Setup app shortcuts using ShortcutManager
            val shortcutManager = getSystemService(android.content.pm.ShortcutManager::class.java)
            val shortcutInfos = mutableListOf<android.content.pm.ShortcutInfo>()

            for (shortcut in shortcuts) {
                val id = shortcut["id"] as String
                val shortLabel = shortcut["shortLabel"] as String
                val longLabel = shortcut["longLabel"] as String
                val intentAction = shortcut["intent"] as String

                val intent = Intent(this, MainActivity::class.java).apply {
                    action = intentAction
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                }

                val shortcutInfo = android.content.pm.ShortcutInfo.Builder(this, id)
                    .setShortLabel(shortLabel)
                    .setLongLabel(longLabel)
                    .setIntent(intent)
                    .build()

                shortcutInfos.add(shortcutInfo)
            }

            shortcutManager?.dynamicShortcuts = shortcutInfos
        }
    }

    private fun shareText(text: String?) {
        text?.let {
            val shareIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, text)
            }
            startActivity(Intent.createChooser(shareIntent, "Share Task"))
        }
    }

    private fun isAppInstalled(packageName: String?): Boolean {
        return try {
            packageName?.let {
                packageManager.getPackageInfo(it, 0)
                true
            } ?: false
        } catch (e: Exception) {
            false
        }
    }

    private fun initializeWidgets() {
        // Widget initialization logic
        // This can include setting up widget update receivers, etc.
    }

    private fun updateWidget(widgetType: String?, data: Map<String, Any>?) {
        // Update widget with new data
        // This would typically involve sending a broadcast to widget providers
        widgetType?.let { type ->
            val intent = Intent("com.example.task_tracker_app.UPDATE_WIDGET").apply {
                putExtra("widgetType", type)
                putExtra("data", data?.let { HashMap(it) })
            }
            sendBroadcast(intent)
        }
    }

    private fun configureWidget(widgetType: String?, settings: Map<String, Any>?) {
        // Configure widget settings
        widgetType?.let { type ->
            val intent = Intent("com.example.task_tracker_app.CONFIGURE_WIDGET").apply {
                putExtra("widgetType", type)
                putExtra("settings", settings?.let { HashMap(it) })
            }
            sendBroadcast(intent)
        }
    }

    private fun removeWidget(widgetId: String?) {
        // Remove widget
        widgetId?.let { id ->
            val intent = Intent("com.example.task_tracker_app.REMOVE_WIDGET").apply {
                putExtra("widgetId", id)
            }
            sendBroadcast(intent)
        }
    }
}