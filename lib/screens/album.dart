import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../consts/consts.dart';
import 'gallery.dart';
import 'imagepreview.dart';

class FolderContentsPage extends StatefulWidget {
  final String? folderName;
  final List<File>? folderContents; // Images from homepage
  final Function(List<File>)? updateFolderContents;

  const FolderContentsPage({
    Key? key,
    required this.folderName,
    required this.updateFolderContents,
    required this.folderContents,
  }) : super(key: key);

  @override
  State<FolderContentsPage> createState() => _FolderContentsPageState();
}

class _FolderContentsPageState extends State<FolderContentsPage> {
  Future<List<File>> retrieveAndCombineImages() async {
    // Retrieve images from the Hive database
    final databaseImages = await retrieveImagesFromHive();

    // Create a set of image file paths already in the Hive database
    final databaseImagePaths = Set<String>();
    for (var file in databaseImages) {
      databaseImagePaths.add(file.path);
    }

    // Check and save new images from folderContents to the Hive database
    for (var file in widget.folderContents!) {
      if (!databaseImagePaths.contains(file.path)) {
        // Save the new image to the Hive database
        await saveImageToHive(file, widget.folderName!);
      }
    }

    // Retrieve the updated images from the database
    final updatedDatabaseImages = await retrieveImagesFromHive();

    // Combine images from homepage and updated database
    final combinedImages = updatedDatabaseImages;

    return combinedImages;
  }

  Future<Uint8List?> generateVideoThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      // Adjust thumbnail size as needed
      quality: 100, // Adjust thumbnail quality as needed
    );
    return thumbnailPath;
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

// Method to delete media (both images and videos) from Hive
  Future<void> deleteMediaFromHive(String mediaPath) async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(widget.folderName!);

    // Remove the entry corresponding to the media path
    await box.delete(mediaPath);
  }

// Method to handle adding a new image
  Future<void> addNewImage(File newImage, String folderName) async {
    // Save the new image to Hive
    await saveImageToHive(newImage, folderName);

    // Update the folder contents list
    widget.folderContents!.add(newImage);

    // Notify the parent widget to update the UI
    if (widget.updateFolderContents != null) {
      widget.updateFolderContents!(widget.folderContents!);
    }
  }

  Future<List<File>> retrieveImagesFromHive() async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(widget.folderName!);
    List<File> retrievedImages = [];

    print(
        "MK: boxKeys:0 ${box.keys} || ${widget.folderName} || ${box.keys.length}");

    // Iterate through the keys in the box
    for (var key in box.keys) {
      final value = box.get(key);
      // print('Key: $key, Value: $value');
      if (value is Uint8List) {
        // print('value is uint8list');
        // Create a temporary directory and save the image file
        final tempDir = await getTemporaryDirectory();
        final fileName = '$key.png';
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(value);
        if (await file.exists()) {
          retrievedImages.add(file);
        }
      } else if (value is String) {
        // Assume it's a video file path
        print('value is string');
        final file = File(value);
        // print('MK: is video Exists: ${key}');
        // Assume it's a video file path
        if (await file.exists()) {
          retrievedImages.add(File(value));
        }
      }
    }
    return retrievedImages.toSet().toList();
  }

  Future<void> _showAddFilesDialog(BuildContext context) async {
    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Transparent background
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Dismiss the dialog on tap
                },
                child: Container(
                  width: 375,
                  height: 812,
                  decoration: BoxDecoration(
                    //color: Colors.black.withOpacity(0.800000011920929),
                  ),
                )),
            // Centered dialog
            Align(
              alignment: Alignment.topCenter,
              child: Dialog(
                backgroundColor: Colors.black.withOpacity(0.800000011920929),
                child: Container(
                  width: 375,
                  height: 812,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/Layer 88.svg'),
                      Center(
                        child: Text(
                          'Add Files',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'You can add Photos and Videos to\nthe album by tapping +',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void initState() {
    super.initState();
    // Show the dialog only when the app is first launched
    _checkFirstLaunch();
    retrieveAndCombineImages();
    //_showAddFilesDialog(context);
  }

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      // Set the flag to false to indicate that the dialog has been shown
      prefs.setBool('first_launch', false);
      // Show the dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddFilesDialog(context);
      });
    }
  }

  Future<List<dynamic>> retrieveMediaFromHive() async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(widget.folderName!);
    List<dynamic> retrievedMedia = [];

    // Iterate through the keys in the box
    // Create a temporary directory and save the image file
    final tempDir = await getTemporaryDirectory();

    print(
        "MK: boxKeys:4 ${box.keys} || ${widget.folderName} || ${box.keys.length}");

    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Uint8List) {
        // Assume it's an image
        final fileName = '$key.png';
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(value);
        // retrievedMedia.add(file);
        // file.delete();
        // await deleteMediaFromHive(file.path);
        // print('MK: image Exists: ${await file.exists()}');
        if (await file.exists()) {
          retrievedMedia.add(file);
        }
        // else {
        //   print('MK: removing image ${value}');
        //   await deleteMediaFromHive(file.path);
        // }
      } else if ((value is String)) {
        final file = File(value);
        // print('MK: is video Exists: ${key}');
        // Assume it's a video file path
        if (await file.exists()) {
          retrievedMedia.add(value);
        }
        // else {
        //   print('MK: removing video ${value}');
        //   await deleteMediaFromHive(value);
        // }
      }
    }
    return retrievedMedia.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.07),
        child: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Color(0xFFFFFFFF) // Color for light theme
              : Consts.FG_COLOR,
          title: Text(
            widget.folderName!,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontFamily: 'GilroyBold',
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                dynamic res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GalleryScreen(folderName: widget.folderName)));
                if (res == true) {
                  setState(() {});
                }
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
      body: FutureBuilder<List<dynamic>>(
        future: retrieveMediaFromHive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            List<dynamic> combinedMedia = snapshot.data!;
            print('MK: combinedMedia: ${combinedMedia}');
            if (combinedMedia.isEmpty) {
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
              // print('MK: combinedMedia: ${combinedMedia.length} for $combinedMedia');
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: combinedMedia.length,
                itemBuilder: (context, index) {
                  final media = combinedMedia[index];
                  print('MK: media is File: ${media is File}');
                  if (media is File) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewScreen(
                              imageFile: media,
                              imageName: media.path.split('/').last,
                              onImageRemoved: (removedMedia) async {
                                setState(() {
                                  combinedMedia.removeWhere((item) {
                                    if (item is File) {
                                      return item == removedMedia;
                                    } else if (item is String) {
                                      return item == removedMedia.path;
                                    }
                                    return false;
                                  });
                                });

                                // Delete the media from the database
                                if (removedMedia is File) {
                                  await deleteMediaFromHive(removedMedia.path);
                                }
                              },
                              folderName: widget.folderName,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            media,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  } else if (media is String) {
                    return FutureBuilder<Uint8List?>(
                      future: generateVideoThumbnail(media),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            color: Colors.grey,
                          );
                        } else if (snapshot.hasData) {
                          return GestureDetector(
                            onTap: () {
                              final videoName = media.split('/').last;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImagePreviewScreen(
                                    imageFile: File(media),
                                    // Replace 'file' with 'media'
                                    imageName: videoName,
                                    onImageRemoved: (removedMedia) async {
                                      setState(() {
                                        combinedMedia.removeWhere((item) {
                                          if (item is File) {
                                            return item == removedMedia;
                                          } else if (item is String) {
                                            return item == removedMedia.path;
                                          }
                                          return false;
                                        });
                                      });

                                      // Delete the media from the database
                                      if (removedMedia is File) {
                                        await deleteMediaFromHive(
                                            removedMedia.path);
                                      }
                                    },
                                    // folderName: '',
                                    folderName: widget.folderName,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              );
            }
          } else {
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
