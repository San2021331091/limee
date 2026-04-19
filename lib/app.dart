import 'package:flutter/material.dart';
import 'package:wallpaper/custom/scroll_behavior.dart';
import 'package:wallpaper/home/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: NewScrollBehavior(),
      home: HomePage(),
      ); 
  }
}