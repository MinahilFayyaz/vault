import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SavedImagesScreen extends StatelessWidget {
  final List<Uint8List> images;

  const SavedImagesScreen({Key? key, required this.images}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Images'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1 / 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(7.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(images[index], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
