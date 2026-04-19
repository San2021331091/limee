import 'package:flutter/material.dart';
import 'package:wallpaper/image_grid/image_grid.dart';
import 'package:wallpaper/search/search.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = "";

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

          SearchWidget(
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            onSubmitted: (value) {
              setState(() {
                _query = value;
              });
            },
            onClear: () {
              setState(() {
                _query = "";
              });
            },
          ),

          const SizedBox(height: 10),
          Expanded(
            child: ImageGridWidget(
              query: _query, 
            ),
          ),
        ],
      ),
    );
  }
}