import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper/modal/modal.dart';
import 'package:wallpaper/repo/repository.dart';
import 'package:wallpaper/video_preview/video_preview_widget.dart';

class VideoGridWidget extends StatefulWidget {
  final String? query;

  const VideoGridWidget({super.key, this.query});

  @override
  State<VideoGridWidget> createState() => _VideoGridWidgetState();
}

class _VideoGridWidgetState extends State<VideoGridWidget> {
  final Repository repository = Repository();
  final ScrollController scrollController = ScrollController();

  List<Video> videos = [];

  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  // 🎯 Effective query: user's query OR a popular default
  String get _effectiveQuery {
    final q = widget.query?.trim() ?? '';
    return q.isEmpty ? "nature" : q;
  }

  @override
  void initState() {
    super.initState();
    fetchVideos();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300 &&
        !isLoading &&
        hasMore) {
      fetchVideos();
    }
  }

  @override
  void didUpdateWidget(covariant VideoGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.query != widget.query) {
      reset();
    }
  }

  void reset() {
    setState(() {
      videos = [];
      pageNumber = 1;
      hasMore = true;
    });

    fetchVideos();
  }

  Future<void> fetchVideos() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      final newVideos = await repository.searchVideos(
        query: _effectiveQuery, // 👈 uses default if empty
        pageNumber: pageNumber,
      );

      if (newVideos.isEmpty) {
        hasMore = false;
      } else {
        pageNumber++;
        videos.addAll(newVideos);

        if (pageNumber > 20) hasMore = false;
      }
    } catch (e) {
      hasMore = false;
      debugPrint("Video fetch error: $e");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (videos.isEmpty && !isLoading) {
      return const Center(child: Text("No videos found"));
    }

    return MasonryGridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(5),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemCount: videos.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= videos.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final video = videos[index];

        return GestureDetector(
          onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPreviewScreen(video: video)));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Image.network(
                    video.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Container(color: Colors.black26),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}