class Images {
  final int imageID;
  final String imageAlt;
  final String imageProtraitPath;

  Images({
    required this.imageID,
     required this.imageAlt,
    required this.imageProtraitPath,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
        imageID: json['id'] ?? 0,
        imageAlt: json['alt'] ?? '',
        imageProtraitPath: json['src']?['portrait'] ?? '',
      );

  Images.emptyConstructor({
    this.imageID = 0,
    this.imageAlt = '',
    this.imageProtraitPath = '',
  });
}

class Video {
  final int id;
  final String videoUrl;
  final String image;

  Video({
    required this.id,
    required this.videoUrl,
    required this.image,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    final files = (json['video_files'] as List?) ?? [];

    String url = '';

    // Prefer HD mp4, fall back to any mp4, then anything with a link
    final hd = files.firstWhere(
      (f) =>
          f['quality'] == 'hd' &&
          f['link'] != null &&
          f['link'].toString().endsWith('.mp4'),
      orElse: () => null,
    );

    if (hd != null) {
      url = hd['link'];
    } else {
      for (final f in files) {
        final link = f['link']?.toString() ?? '';
        if (link.endsWith('.mp4')) {
          url = link;
          break;
        }
      }
    }

    return Video(
      id: json['id'] ?? 0,
      videoUrl: url,
      image: json['image'] ?? '',
    );
  }

  bool get isValid => videoUrl.isNotEmpty && image.isNotEmpty;
}

class Category {
  final String name;
  final String previewUrl;

  Category({required this.name, required this.previewUrl});
}