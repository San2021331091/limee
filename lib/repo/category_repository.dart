import 'package:flutter/material.dart';
import 'package:wallpaper/modal/modal.dart';
import 'package:wallpaper/repo/repository.dart';

class CategoryRepository {
  final Repository repo = Repository();

  // ----------------------------
  // 🖼 IMAGE CATEGORY LIST
  // ----------------------------
  final List<String> imageCategoryNames = [
    "Amoled",
    "Minimal",
    "Dark",
    "Abstract",
    "Gradient",
    "Mountains",
    "Space",
    "Neon",
    "Cyberpunk",
    "Cars",
    "Anime",
    "Gaming",
    "Technology",
    "Architecture",
    "City",
    "Night",
    "Flowers",
    "Food",
    "Sports",
  ];

  // ----------------------------
  // 🎬 VIDEO CATEGORY LIST
  // ----------------------------
  final List<String> videoCategoryNames = [
    "Aquarium",
    "Nature",
    "Ocean",
    "Wildlife",
    "Rain",
    "Waterfall",
    "Forest",
    "Sky",
    "Fireplace",
  ];

  // ----------------------------
  // 🖼 IMAGE CATEGORIES
  // ----------------------------
  Future<List<Category>> getImageCategories() async {
    final List<Category> categories = [];

    for (final name in imageCategoryNames) {
      try {
        final images = await repo.searchImages(query: name);

        if (images.isEmpty) continue;

        final preview = images.first.imageProtraitPath;
        if (preview.isEmpty) continue;

        categories.add(Category(name: name, previewUrl: preview));
      } catch (e) {
        debugPrint("Image category error [$name]: $e");
      }
    }

    return categories;
  }

  // ----------------------------
  // 🎬 VIDEO CATEGORIES
  // ----------------------------
  Future<List<Category>> getVideoCategories() async {
    final List<Category> categories = [];

    for (final name in videoCategoryNames) {
      try {
        final videos = await repo.searchVideos(query: name);

        if (videos.isEmpty) continue;

        // ✅ Find first video with a REAL image thumbnail, never an .mp4
        String preview = '';
        for (final v in videos) {
          final img = v.image.toLowerCase();
          if (v.image.isNotEmpty &&
              !img.endsWith('.mp4') &&
              !img.endsWith('.mov') &&
              !img.endsWith('.webm')) {
            preview = v.image;
            break;
          }
        }

        if (preview.isEmpty) continue;

        categories.add(Category(name: name, previewUrl: preview));
      } catch (e) {
        debugPrint("Video category error [$name]: $e");
      }
    }

    return categories;
  }
}