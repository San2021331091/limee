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