import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:wallpaper/modal/modal.dart';

class Repository {
  final String apiKey =
      "UFeKvgf6kK9PPkBgNTkuuxWJWG4v67egJRAmXzul7Dcn63Sd7BCWmeOO";

  final String baseURL = "https://api.pexels.com/v1/";
  final String videoBaseURL = "https://api.pexels.com/videos/";

  final Dio _dio = Dio();

  Options _options() => Options(
        headers: {"Authorization": apiKey},
      );

  /// 🔍 Regex validation (letters + numbers + spaces)
  final RegExp _regex = RegExp(r'^[a-zA-Z0-9\s]+$');

  /// 📸 Get curated images
  Future<List<Images>> getImageList({int? pageNumber}) async {
    final String url =
        "${baseURL}curated?per_page=80${pageNumber != null ? "&page=$pageNumber" : ""}";

    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        final data = response.data;
        final List photos = data['photos'] ?? [];

        return photos.map<Images>((e) => Images.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    return [];
  }

  /// 📸 Get image by ID
  Future<Images> getImageByID({required int imageID}) async {
    final String url = "${baseURL}photos/$imageID";

    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        return Images.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    return Images.emptyConstructor();
  }

  /// 🔍 Search Images
  Future<List<Images>> searchImages({
    required String query,
    int? pageNumber,
  }) async {
    if (!_regex.hasMatch(query)) {
      debugPrint("Invalid query");
      return [];
    }

    final String url =
        "${baseURL}search?query=${Uri.encodeComponent(query)}&per_page=80${pageNumber != null ? "&page=$pageNumber" : ""}";

    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        final data = response.data;
        final List photos = data['photos'] ?? [];

        return photos.map<Images>((e) => Images.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    return [];
  }

  /// 🎬 Search Videos
  Future<List<Video>> searchVideos({
    required String query,
    int? pageNumber,
  }) async {
    if (!_regex.hasMatch(query)) {
      debugPrint("Invalid query");
      return [];
    }

    final String url =
        "${videoBaseURL}search?query=${Uri.encodeComponent(query)}&per_page=40${pageNumber != null ? "&page=$pageNumber" : ""}";

    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        final data = response.data;
        final List videos = data['videos'] ?? [];

        return videos.map<Video>((e) => Video.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    return [];
  }

  /// 🔥 Combined Search (Images + Videos)
  Future<Map<String, dynamic>> searchAll({
    required String query,
    int? pageNumber,
  }) async {
    if (!_regex.hasMatch(query)) {
      debugPrint("Invalid query");
      return {
        "images": <Images>[],
        "videos": <Video>[],
      };
    }

    final results = await Future.wait([
      searchImages(query: query, pageNumber: pageNumber),
      searchVideos(query: query, pageNumber: pageNumber),
    ]);

    return {
      "images": results[0],
      "videos": results[1],
    };
  }

  /// ⬇️ Download Image
  Future<void> downloadImage({
    required String imageURL,
    required int imageID,
    required BuildContext context,
  }) async {
    final response = await _dio.get(
      imageURL,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      final bytes = response.data;

      final directory =
          await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOAD);

      final file = File("$directory/$imageID.png");
      await file.writeAsBytes(bytes);

      MediaScanner.loadMedia(path: file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content:
                Text("Image Downloaded Successfully at ${file.path}!"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}