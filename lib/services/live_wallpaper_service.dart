import 'package:flutter/services.dart';

class LiveWallpaperService {
  static const _channel =
      MethodChannel('com.example.wallpaper/video_wallpaper');

  /// Launches the system live-wallpaper chooser pointing at our service.
  /// User still has to confirm in the system UI.
  static Future<bool> setVideoWallpaper(String localFilePath) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'setVideoWallpaper',
        {'path': localFilePath},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception("Live wallpaper error: ${e.message}");
    }
  }
}