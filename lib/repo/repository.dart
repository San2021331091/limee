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

  final Dio _dio = Dio();
  Options _options() => Options(
        headers: {"Authorization": apiKey},
      );
  Future<List<Images>> getImageList({int? pageNumber}) async {
    final String url =
        "${baseURL}curated?per_page=80${pageNumber != null ? "&page=$pageNumber" : ""}";
    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;

        final List<dynamic> photos = data['photos'] ?? [];

        return photos
            .map<Images>((json) => Images.fromJson(json))
            .toList();
      } else {
        debugPrint("Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    }

    return [];
  }

  Future<Images> getImageByID({required int imageID}) async {
    final String url = "${baseURL}photos/$imageID";

    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;

        return Images.fromJson(data);
      } else {
        debugPrint("Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    }

    return Images.emptyConstructor(); 
  }
  Future<List<Images>> searchImages({required String query, int? pageNumber}) async {
    final String url =
        "${baseURL}search?query=$query&per_page=80${pageNumber != null ? "&page=$pageNumber" : ""}";

    try {
      final response = await _dio.get(url, options: _options());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;

        final List<dynamic> photos = data['photos'] ?? [];

        return photos
            .map<Images>((json) => Images.fromJson(json))
            .toList();
      } else {
        debugPrint("Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    }

    return [];
  }

  Future<void> downloadImage({
    required String imageURL,required int imageID, required BuildContext context
  }) async{
      final response = await _dio.get(
      imageURL,
      options: Options(responseType: ResponseType.bytes),
    );
    if(response.statusCode == 200){
      final bytes = response.data;
      final directory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
      final file = File("$directory/$imageID.png");
      await file.writeAsBytes(bytes);

      MediaScanner.loadMedia(path: file.path);
      if(context.mounted){
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Image Downloaded Successfully at ${file.path}!"),
            duration: Duration(seconds: 3),),
        );
      }
    }
  }
}