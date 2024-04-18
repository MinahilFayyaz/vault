// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
//
// import 'gallery.dart';
//
// class SelectedImagesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Selected Images'),
//       ),
//       body: ValueListenableBuilder<Box<SelectedImage>>(
//         valueListenable: Hive.box<SelectedImage>('selected_images').listenable(),
//         builder: (BuildContext context, Box<SelectedImage> selectedImagesBox, _) {
//         final selectedImages = selectedImagesBox.values.toList();
//           return ListView.builder(
//             itemCount: selectedImages.length,
//             itemBuilder: (BuildContext context, int index) {
//               final selectedImage = selectedImages[index];
//               return ListTile(
//                 leading: Image.file(File(selectedImage.imageUrl)),
//                 title: Text(selectedImage.timestamp.toString()),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
