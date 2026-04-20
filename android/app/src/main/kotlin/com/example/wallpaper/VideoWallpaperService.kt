package com.example.wallpaper

import android.content.SharedPreferences
import android.net.Uri
import android.service.wallpaper.WallpaperService
import android.util.Log
import android.view.SurfaceHolder
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer

class VideoWallpaperService : WallpaperService() {

    companion object {
        private const val TAG = "VideoWallpaper"
    }

    override fun onCreateEngine(): Engine = VideoEngine()

    private inner class VideoEngine : Engine() {
        private var player: ExoPlayer? = null
        private var prefs: SharedPreferences? = null
        private var currentSurfaceHolder: SurfaceHolder? = null
        private var isVisibleNow = false

        override fun onCreate(surfaceHolder: SurfaceHolder) {
            super.onCreate(surfaceHolder)
            prefs = getSharedPreferences("video_wallpaper_prefs", MODE_PRIVATE)
            setTouchEventsEnabled(false)
            Log.d(TAG, "Engine onCreate")
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            currentSurfaceHolder = holder
            Log.d(TAG, "Surface created: ${holder.surface.isValid}")
            initPlayerIfNeeded()
        }

        override fun onSurfaceChanged(
            holder: SurfaceHolder,
            format: Int,
            width: Int,
            height: Int
        ) {
            super.onSurfaceChanged(holder, format, width, height)
            currentSurfaceHolder = holder
            Log.d(TAG, "Surface changed: ${width}x${height}")
            // Re-bind surface on every change (critical for some devices)
            player?.setVideoSurface(holder.surface)
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            Log.d(TAG, "Surface destroyed")
            player?.setVideoSurface(null)
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            isVisibleNow = visible
            Log.d(TAG, "Visibility: $visible")

            if (visible) {
                initPlayerIfNeeded()
                player?.play()
            } else {
                player?.pause()
            }
        }

        override fun onDestroy() {
            super.onDestroy()
            Log.d(TAG, "Engine destroyed")
            releasePlayer()
        }

        private fun initPlayerIfNeeded() {
            val holder = currentSurfaceHolder ?: return
            if (player != null) {
                // Re-bind in case surface was recreated
                player?.setVideoSurface(holder.surface)
                return
            }

            val path = prefs?.getString("video_path", null)
            if (path.isNullOrEmpty()) {
                Log.e(TAG, "No video path in prefs!")
                return
            }

            Log.d(TAG, "Creating ExoPlayer for: $path")

            try {
                val exo = ExoPlayer.Builder(this@VideoWallpaperService)
                    .build()
                    .apply {
                        setVideoSurface(holder.surface)
                        setMediaItem(MediaItem.fromUri(Uri.parse(path)))
                        repeatMode = Player.REPEAT_MODE_ALL
                        volume = 0f
                        // "zoom" fills the wallpaper even if aspect differs
                        videoScalingMode = C.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING
                        addListener(object : Player.Listener {
                            override fun onPlaybackStateChanged(state: Int) {
                                val s = when (state) {
                                    Player.STATE_IDLE -> "IDLE"
                                    Player.STATE_BUFFERING -> "BUFFERING"
                                    Player.STATE_READY -> "READY"
                                    Player.STATE_ENDED -> "ENDED"
                                    else -> "UNKNOWN"
                                }
                                Log.d(TAG, "Playback state: $s")
                            }

                            override fun onPlayerError(error: PlaybackException) {
                                Log.e(TAG, "ExoPlayer error: ${error.message}", error)
                            }

                            override fun onIsPlayingChanged(isPlaying: Boolean) {
                                Log.d(TAG, "Is playing: $isPlaying")
                            }
                        })
                        prepare()
                        playWhenReady = isVisibleNow
                    }

                player = exo
            } catch (e: Exception) {
                Log.e(TAG, "initPlayer failed", e)
            }
        }

        private fun releasePlayer() {
            player?.release()
            player = null
        }
    }
}