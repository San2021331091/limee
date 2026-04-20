import 'package:flutter/material.dart';
import 'package:wallpaper/category_list/category_list_widget.dart';
import 'package:wallpaper/image_grid/image_grid.dart';
import 'package:wallpaper/search/search.dart';
import 'package:wallpaper/video_grid/video_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = "";
  String _type = "images"; // 🔥 controlled here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Live",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                  fontSize: 22,
                ),
              ),
              SizedBox(width: 5),
              Text(
                "Wallpaper",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔍 SEARCH
          SearchWidget(
            onChanged: (value) => setState(() => _query = value),
            onSubmitted: (value) => setState(() => _query = value),
            onClear: () => setState(() => _query = ""),
          ),

          const SizedBox(height: 20),

          // ✅ SINGLE TOGGLE (ONLY HERE)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toggle("Images", "images"),
              const SizedBox(width: 10),
              _toggle("Videos", "videos"),
            ],
          ),

          const SizedBox(height: 20),

          // 📂 CATEGORY LIST (type passed from parent)
          CategoryListWidget(
            type: _type, // 🔥 important
            onCategorySelected: (type, category) {
              setState(() {
                _type = type;
                _query = category;
              });
            },
          ),

          const SizedBox(height: 10),

          // 📌 GRID SWITCH
          Expanded(
            child: _type == "images"
                ? ImageGridWidget(query: _query)
                : VideoGridWidget(query: _query),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🔘 TOGGLE BUTTON
  // =========================
  Widget _toggle(String label, String type) {
    final active = _type == type;

    return GestureDetector(
      onTap: () {
        if (_type == type) return; // ✅ prevent unnecessary rebuild

        setState(() {
          _type = type;
          _query = ""; // optional: reset search when switching
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}