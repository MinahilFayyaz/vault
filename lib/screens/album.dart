import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../consts/consts.dart';
import 'gallery.dart';
import 'imagepreview.dart';

class FolderContentsPage extends StatelessWidget {
  final String? folderName;
  final List<File>? folderContents;  // Images from homepage
  final Function(List<File>)? updateFolderContents;

  const FolderContentsPage({
    Key? key,
    required this.folderName,
    required this.updateFolderContents,
    required this.folderContents,
  }) : super(key: key);

  // Retrieve images from Hive and combine them with images from homepage
  // Future<List<File>> retrieveAndCombineImages() async {
  //   // Retrieve images from the database
  //   final databaseImages = await retrieveImagesFromHive();
  //
  //   // Combine images from homepage and database
  //   final combinedImages = [...folderContents!, ...databaseImages];
  //
  //   return combinedImages;
  // }

  Future<List<File>> retrieveAndCombineImages() async {
    // Retrieve images from the Hive database
    final databaseImages = await retrieveImagesFromHive();

    // Create a set of image file paths already in the Hive database
    final databaseImagePaths = Set<String>();
    for (var file in databaseImages) {
      databaseImagePaths.add(file.path);
    }

    // Check and save new images from folderContents to the Hive database
    for (var file in folderContents!) {
      if (!databaseImagePaths.contains(file.path)) {
        // Save the new image to the Hive database
        await saveImageToHive(file, folderName!);
      }
    }

    // Retrieve the updated images from the database
    final updatedDatabaseImages = await retrieveImagesFromHive();

    // Combine images from homepage and updated database
    final combinedImages = updatedDatabaseImages;

    return combinedImages;
  }

  // Method to save an image file to Hive
  Future<void> saveImageToHive(File imageFile, String folderName) async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(folderName);

    // Read the image file as bytes
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Use the file path as the key to store the image bytes in the box
    final key = imageFile.path.split('/').last;

    // Store the image bytes in the box
    await box.put(key, imageBytes);
  }

// Method to handle adding a new image
  Future<void> addNewImage(File newImage, String folderName) async {
    // Save the new image to Hive
    await saveImageToHive(newImage, folderName);

    // Update the folder contents list
    folderContents!.add(newImage);

    // Notify the parent widget to update the UI
    if (updateFolderContents != null) {
      updateFolderContents!(folderContents!);
    }
  }


  // Method to retrieve images from Hive
  // Future<List<File>> retrieveImagesFromHive() async {
  //   final box = await Hive.openBox('myBox');
  //   List<File> retrievedImages = [];
  //
  //   // Iterate through the keys in the box
  //   for (var key in box.keys) {
  //     final value = box.get(key);
  //     if (value is Uint8List) {
  //       // Create a temporary directory and save the image file
  //       final tempDir = await getTemporaryDirectory();
  //       final fileName = '$key.png';
  //       final filePath = '${tempDir.path}/$fileName';
  //       final file = File(filePath);
  //       await file.writeAsBytes(value);
  //       retrievedImages.add(file);
  //     }
  //   }
  //   return retrievedImages;
  // }


  // Method to retrieve images from a specific folder name Hive box
  Future<List<File>> retrieveImagesFromHive() async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(folderName!);
    List<File> retrievedImages = [];

    // Iterate through the keys in the box
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Uint8List) {
        // Create a temporary directory and save the image file
        final tempDir = await getTemporaryDirectory();
        final fileName = '$key.png';
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(value);
        retrievedImages.add(file);
      }
    }

    return retrievedImages;
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.07),
        child: AppBar(
          title: Text(
            folderName!,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontFamily: 'GilroyBold',
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => GalleryScreen(folderName: folderName)));
              },
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Container(
                  height: screenHeight * 0.05,
                  width: screenHeight * 0.05,
                  decoration: BoxDecoration(
                    color: Consts.COLOR,
                    borderRadius: BorderRadius.circular(screenHeight * 0.01),
                  ),
                  child: Icon(
                    Icons.add,
                    size: screenWidth * 0.06,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<File>>(
        future: retrieveAndCombineImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while data is loading
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            List<File> combinedImages = snapshot.data!;

            // If there are no files, display a "No File Found" message
            if (combinedImages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/folder (2) 1.svg'),
                    const SizedBox(height: 16),
                    const Text(
                      'No File Found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'There is no file in the album yet!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Display the images in a grid view
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: combinedImages.length,
                  itemBuilder: (context, index) {
                    final imageFile = combinedImages[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewScreen(
                              imageFile: imageFile,
                              imageName: imageFile.path.split('/').last,
                              onImageRemoved: (removedImage) {
                                // Remove the removed image from the combinedImages list
                                updateFolderContents!(
                                    combinedImages.where((image) => image != removedImage).toList()
                                );
                              }, folderName: folderName,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0,
                        horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }

              );
            }
          } else {
            // Display a message if there was an error or data isn't available
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/folder (2) 1.svg'),
                  const SizedBox(height: 16),
                  const Text(
                    'No File Found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'There is no file in the album yet!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
