import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper/modal/modal.dart';
import 'package:wallpaper/repo/repository.dart';

class ImageGridWidget extends StatefulWidget {
  final String query;

  const ImageGridWidget({
    super.key,
    required this.query,
  });

  @override
  State<ImageGridWidget> createState() => _ImageGridWidgetState();
}

class _ImageGridWidgetState extends State<ImageGridWidget> {
  final Repository repository = Repository();
  final ScrollController scrollController = ScrollController();

  List<Images> images = [];

  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchImages();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchImages();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ImageGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 When search query changes → reset everything
    if (oldWidget.query != widget.query) {
      resetAndFetch();
    }
  }

  void resetAndFetch() {
    setState(() {
      images.clear();
      pageNumber = 1;
      hasMore = true;
    });

    fetchImages();
  }

  Future<void> fetchImages() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      List<Images> newImages = [];

      if (widget.query.isEmpty) {
        // 📸 Default feed
        newImages =
            await repository.getImageList(pageNumber: pageNumber);
      } else {
        // 🔍 Search mode
        newImages = await repository.searchImages(
          query: widget.query,
          pageNumber: pageNumber,
        );
      }

      if (newImages.isEmpty) {
        hasMore = false;
      } else {
        pageNumber++;
        images.addAll(newImages);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty && isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
          backgroundColor: Colors.red,
        ),
      );
    }

    if (images.isEmpty && !isLoading) {
      return const Center(
        child: Text(
          "No results found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return MasonryGridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(5),
      gridDelegate:
          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemCount: images.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= images.length) {
          return const Padding(
            padding: EdgeInsets.all(10),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final image = images[index];

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: image.imageProtraitPath,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error),
          ),
        );
      },
    );
  }
}