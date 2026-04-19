import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper/modal/modal.dart';
import 'package:wallpaper/repo/repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Repository repository = Repository();
  ScrollController scrollController = ScrollController();
  late Future<List<Images>> imagesList;
  int pageNumber = 1;
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    imagesList = repository.getImageList(pageNumber: pageNumber);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: const Row(
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
      body: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
             FutureBuilder(future: imagesList, builder: (context,snapShot){
              if(snapShot.connectionState == ConnectionState.done){
               if(snapShot.hasError){
                return const Center(child: Text("Error Occured"));
        
               }
               return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 5),
                  child: MasonryGridView.count(
                   itemCount: snapShot.data?.length, 
                    crossAxisCount: 2, 
    
                  shrinkWrap: true,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  itemBuilder:(context, index){
                    double height = (index % 10 + 1) * 100;
                 return GestureDetector(
                    child: ClipRect(
                      child: CachedNetworkImage(imageUrl: snapShot.data!
                      [index].imageProtraitPath,
                      height: height > 300 ? 300 : height,
                      fit: BoxFit.cover,
                      ),
                    ),
                  );
                  }),
                  ),
                  

                ],
               );

              }
              else{
                return const Center(child: CircularProgressIndicator());
              }

             }
             
             
             )        
          ],
        ),
      ),
    );
  }
}