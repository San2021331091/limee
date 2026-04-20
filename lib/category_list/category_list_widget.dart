import 'package:flutter/material.dart';
import 'package:wallpaper/modal/modal.dart';
import 'package:wallpaper/repo/category_repository.dart';

class CategoryListWidget extends StatefulWidget {
  final String type; // 🔥 comes from HomePage
  final Function(String type, String category) onCategorySelected;

  const CategoryListWidget({
    super.key,
    required this.type,
    required this.onCategorySelected,
  });

  @override
  State<CategoryListWidget> createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  final CategoryRepository repo = CategoryRepository();

  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  void didUpdateWidget(covariant CategoryListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.type != widget.type) {
      setState(() {
        isLoading = true;
        categories = [];
      });

      loadCategories();
    }
  }

  // =========================
  // 📦 LOAD BASED ON TYPE
  // =========================
  Future<void> loadCategories() async {
    try {
      final result = widget.type == "videos"
          ? await repo.getVideoCategories()
          : await repo.getImageCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Category load error: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ✅ Only allow real image URLs as backgrounds
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    // Reject video file extensions
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m4v')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text("No categories found"))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _buildCategoryCard(cat);
                  },
                ),
    );
  }

  Widget _buildCategoryCard(Category cat) {
    final isImage = _isValidImageUrl(cat.previewUrl);

    return GestureDetector(
      onTap: () => widget.onCategorySelected(widget.type, cat.name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade300, // fallback background
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🖼 Background image (safe + with error handling)
            if (isImage)
              Image.network(
                cat.previewUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
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
              )
            else
              Container(
                color: Colors.grey.shade400,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white70,
                ),
              ),

            // 🌈 Gradient overlay for text legibility
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 🏷 Category name
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(blurRadius: 6, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}