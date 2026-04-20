package com.example.wallpaper

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.wallpaper/video_wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setVideoWallpaper" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrEmpty()) {
                        result.error("BAD_PATH", "Video path is empty", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val prefs = getSharedPreferences(
                            "video_wallpaper_prefs",
                            Context.MODE_PRIVATE
                        )
                        prefs.edit().putString("video_path", path).apply()

                        val intent = Intent(
                            WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER
                        )
                        intent.putExtra(
                            WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                            ComponentName(
                                this@MainActivity,
                                VideoWallpaperService::class.java
                            )
                        )
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("WALLPAPER_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}