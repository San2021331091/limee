import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

import 'package:wallpaper/repo/repository.dart';
import 'package:wallpaper/modal/modal.dart';

class ImagePreviewScreen extends StatefulWidget {
  final Images image;

  const ImagePreviewScreen({
    super.key,
    required this.image,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final Repository repository = Repository();
  final WallpaperManagerFlutter _wallpaperManager = WallpaperManagerFlutter();
  bool isLoading = false;

  Future<File> _downloadToFile() async {
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/${widget.image.imageID}.jpg";

    await Dio().download(
      widget.image.imageProtraitPath,
      filePath,
    );

    return File(filePath);
  }

  Future<void> _setWallpaper(int type) async {
    setState(() => isLoading = true);

    try {
      final file = await _downloadToFile();
      await _wallpaperManager.setWallpaper(file, type);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Wallpaper Applied Successfully"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Wallpaper error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed to set wallpaper"),
          ),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  /// ✅ IMPROVED WALLPAPER OPTIONS (NO PREVIEW)
  void _showWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Set Wallpaper",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _wallpaperOption(
                    icon: Icons.home,
                    label: "Home",
                    onTap: () {
                      Navigator.pop(context);
                      _setWallpaper(WallpaperManagerFlutter.homeScreen);
                    },
                  ),
                  _wallpaperOption(
                    icon: Icons.lock,
                    label: "Lock",
                    onTap: () {
                      Navigator.pop(context);
                      _setWallpaper(WallpaperManagerFlutter.lockScreen);
                    },
                  ),
                  _wallpaperOption(
                    icon: Icons.phone_android,
                    label: "Both",
                    onTap: () {
                      Navigator.pop(context);
                      _setWallpaper(WallpaperManagerFlutter.bothScreens);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 small reusable widget
  Widget _wallpaperOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _download() async {
    setState(() => isLoading = true);

    await repository.downloadImage(
      imageURL: widget.image.imageProtraitPath,
      imageID: widget.image.imageID,
      context: context,
    );

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
     
          SizedBox.expand(
            child: Image.network(
              widget.image.imageProtraitPath,
              fit: BoxFit.cover,
            ),
          ),


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

    
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  /// DOWNLOAD
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _download,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download,color: Colors.white,),
                      label: const Text("Download",style: TextStyle(color: Colors.white),),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// WALLPAPER
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          isLoading ? null : _showWallpaperOptions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.wallpaper,color: Colors.white,),
                      label: const Text("Set Wallpaper",style: TextStyle(color: Colors.white),),
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