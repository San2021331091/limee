import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wallpaper/repo/repository.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:wallpaper/modal/modal.dart';
import 'package:wallpaper/services/live_wallpaper_service.dart';

class VideoPreviewScreen extends StatefulWidget {
  final Video video;

  const VideoPreviewScreen({super.key, required this.video});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  final WallpaperManagerFlutter _wallpaperManager = WallpaperManagerFlutter();

  bool isInitialized = false;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );

    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();

      if (!mounted) return;
      setState(() => isInitialized = true);
    } catch (e) {
      debugPrint("Video init error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // ⬇️ DOWNLOAD VIDEO TO PUBLIC DOWNLOADS
  // ============================================================
 Future<void> _downloadVideo() async {
  setState(() => isBusy = true);

  final repository = Repository();
  await repository.downloadVideo(
    videoURL: widget.video.videoUrl,
    videoID: widget.video.id,
    context: context,
  );

  if (mounted) setState(() => isBusy = false);
}

  // ============================================================
  // 📥 DOWNLOAD VIDEO INTO APP INTERNAL STORAGE (for live wallpaper)
  // ============================================================
  Future<File> _downloadVideoToAppStorage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/live_wp_${widget.video.id}.mp4");

    if (!await file.exists()) {
      await Dio().download(widget.video.videoUrl, file.path);
    }
    return file;
  }

  // ============================================================
  // 🎬 SET AS LIVE VIDEO WALLPAPER (ExoPlayer service) — HOME
  // ============================================================
  Future<void> _setLiveVideoWallpaper() async {
    setState(() => isBusy = true);

    try {
      final file = await _downloadVideoToAppStorage();
      await LiveWallpaperService.setVideoWallpaper(file.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Confirm in the system wallpaper chooser"),
        ),
      );
    } catch (e) {
      debugPrint("Live wallpaper error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to launch wallpaper chooser"),
        ),
      );
    }

    if (mounted) setState(() => isBusy = false);
  }

  // ============================================================
  // 🖼 STATIC THUMBNAIL WALLPAPER — LOCK
  // ============================================================
  Future<File> _downloadThumbToFile() async {
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/wp_${widget.video.id}.jpg";

    await Dio().download(widget.video.image, filePath);
    return File(filePath);
  }

  Future<void> _setStaticWallpaper(int type) async {
    setState(() => isBusy = true);

    try {
      final file = await _downloadThumbToFile();
      await _wallpaperManager.setWallpaper(file, type);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Lock screen wallpaper applied"),
        ),
      );
    } catch (e) {
      debugPrint("Wallpaper error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to set wallpaper"),
        ),
      );
    }

    if (mounted) setState(() => isBusy = false);
  }

  // ============================================================
  // 📱 BOTH: static on lock, then live on home
  // ============================================================
  Future<void> _setBothWallpapers() async {
    await _setStaticWallpaper(WallpaperManagerFlutter.lockScreen);
    if (!mounted) return;
    await _setLiveVideoWallpaper();
  }

  // ============================================================
  // 📋 WALLPAPER OPTIONS SHEET
  // ============================================================
  void _showWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Set Wallpaper",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🎬 LIVE VIDEO → HOME
            _WallpaperOptionCard(
              icon: Icons.movie_filter,
              iconColor: Colors.deepPurpleAccent,
              bgColor: Colors.deepPurple,
              borderColor: Colors.deepPurpleAccent,
              title: "Live video — Home screen",
              subtitle: "Animated video plays in the background",
              onTap: () {
                Navigator.pop(context);
                _setLiveVideoWallpaper();
              },
            ),

            const SizedBox(height: 12),

            // 🔒 STATIC IMAGE → LOCK
            _WallpaperOptionCard(
              icon: Icons.lock,
              iconColor: Colors.blueAccent,
              bgColor: Colors.blue,
              borderColor: Colors.blueAccent,
              title: "Static image — Lock screen",
              subtitle: "Thumbnail shown on lock screen",
              onTap: () {
                Navigator.pop(context);
                _setStaticWallpaper(WallpaperManagerFlutter.lockScreen);
              },
            ),

            const SizedBox(height: 12),

            // 📱 BOTH
            _WallpaperOptionCard(
              icon: Icons.phone_android,
              iconColor: Colors.green,
              bgColor: Colors.green,
              borderColor: Colors.green,
              title: "Apply to both",
              subtitle: "Live video on home, image on lock",
              onTap: () {
                Navigator.pop(context);
                _setBothWallpapers();
              },
            ),

            const SizedBox(height: 16),

            // ℹ️ DISCLAIMER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                "Android does not support video on the lock screen — a still image is used instead.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🎬 PLAYBACK
  // ============================================================
  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final mm = two(d.inMinutes.remainder(60));
    final ss = two(d.inSeconds.remainder(60));
    return "$mm:$ss";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🎥 VIDEO
          Center(
            child: isInitialized
                ? GestureDetector(
                    onTap: _togglePlayPause,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),

          // 🔙 BACK BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // ▶ CENTER PLAY INDICATOR
          if (isInitialized)
            Center(
              child: AnimatedOpacity(
                opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),

          // 📊 SEEK BAR + CONTROLS
          if (isInitialized)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, VideoPlayerValue value, _) {
                    return Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        Text(
                          _formatDuration(value.position),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            value: value.position.inMilliseconds
                                .toDouble()
                                .clamp(
                                  0.0,
                                  value.duration.inMilliseconds
                                      .toDouble(),
                                ),
                            max: value.duration.inMilliseconds.toDouble(),
                            activeColor: Colors.white,
                            inactiveColor: Colors.white24,
                            onChanged: (v) {
                              _controller.seekTo(
                                Duration(milliseconds: v.toInt()),
                              );
                            },
                          ),
                        ),
                        Text(
                          _formatDuration(value.duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

          // ⬇️ BOTTOM ACTION BAR
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  // DOWNLOAD
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isBusy ? null : _downloadVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: isBusy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        "Download",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // WALLPAPER
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isBusy ? null : _showWallpaperOptions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.wallpaper, color: Colors.white),
                      label: const Text(
                        "Set Wallpaper",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🎨 REUSABLE WALLPAPER OPTION CARD
// ============================================================
class _WallpaperOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WallpaperOptionCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}