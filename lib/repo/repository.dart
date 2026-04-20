import 'dart:io';

import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:wallpaper/modal/modal.dart';

class Repository {
  final String apiKey =
      "UFeKvgf6kK9PPkBgNTkuuxWJWG4v67egJRAmXzul7Dcn63Sd7BCWmeOO";

  final String baseURL = "https://api.pexels.com/v1/";
  final String videoBaseURL = "https://api.pexels.com/videos/";

  final Dio _dio = Dio();

  Options _options() => Options(headers: {"Authorization": apiKey});

  // ----------------------------
  // 📸 CURATED IMAGES
  // ----------------------------
  Future<List<Images>> getImageList({int? pageNumber}) async {
    final url =
        "${baseURL}curated?per_page=80${pageNumber != null ? "&page=$pageNumber" : ""}";

    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        final List photos = response.data['photos'] ?? [];
        return photos.map((e) => Images.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("getImageList error: $e");
    }

    return [];
  }

  // ----------------------------
  // 📸 SEARCH IMAGES
  // ----------------------------
  Future<List<Images>> searchImages({
    required String query,
    int? pageNumber,
  }) async {
    final url =
        "${baseURL}search?query=${Uri.encodeComponent(query)}&per_page=80${pageNumber != null ? "&page=$pageNumber" : ""}";

    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        final List photos = response.data['photos'] ?? [];
        return photos.map((e) => Images.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("searchImages error: $e");
    }

    return [];
  }

  // ----------------------------
  // 🎬 SEARCH VIDEOS
  // ----------------------------
  Future<List<Video>> searchVideos({
    required String query,
    int? pageNumber,
  }) async {
    final url =
        "${videoBaseURL}search?query=${Uri.encodeComponent(query)}&per_page=40${pageNumber != null ? "&page=$pageNumber" : ""}";

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {"Authorization": apiKey},
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List videos = response.data['videos'] ?? [];
        final list = videos.map((e) => Video.fromJson(e)).toList();
        debugPrint("Videos received: ${list.length}");
        return list.where((v) => v.isValid).toList();
      }

      return [];
    } catch (e) {
      debugPrint("searchVideos error: $e");
      return [];
    }
  }

  // ----------------------------
  // 🔥 COMBINED SEARCH
  // ----------------------------
  Future<({List<Images> images, List<Video> videos})> searchAll({
    required String query,
    int? pageNumber,
  }) async {
    try {
      final results = await Future.wait([
        searchImages(query: query, pageNumber: pageNumber),
        searchVideos(query: query, pageNumber: pageNumber),
      ]);

      return (
        images: results[0] as List<Images>,
        videos: results[1] as List<Video>,
      );
    } catch (e) {
      debugPrint("searchAll error: $e");
      return (images: <Images>[], videos: <Video>[]);
    }
  }

  // ----------------------------
  // 📸 DOWNLOAD IMAGE
  // ----------------------------
  Future<void> downloadImage({
    required String imageURL,
    required int imageID,
    required BuildContext context,
  }) async {
    try {
      final response = await _dio.get(
        imageURL,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) return;

      final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );

      final file = File("$directory/$imageID.png");
      await file.writeAsBytes(response.data);
      MediaScanner.loadMedia(path: file.path);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Downloaded: ${file.path}"),
        ),
      );
    } catch (e) {
      debugPrint("downloadImage error: $e");
    }
  }

  // ----------------------------
  // 🎬 DOWNLOAD VIDEO
  // ----------------------------
  Future<void> downloadVideo({
    required String videoURL,
    required int videoID,
    required BuildContext context,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );

      final filePath = "$directory/pexels_$videoID.mp4";

      await _dio.download(
        videoURL,
        filePath,
        onReceiveProgress: (received, total) {
          if (total <= 0 || onProgress == null) return;
          onProgress(received / total);
        },
      );

      MediaScanner.loadMedia(path: filePath);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Downloaded: $filePath"),
        ),
      );
    } catch (e) {
      debugPrint("downloadVideo error: $e");

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Download failed"),
        ),
      );
    }
  }
}