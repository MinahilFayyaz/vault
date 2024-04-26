import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vault/screens/homepage.dart';
import 'package:vault/screens/languages.dart';
import 'package:vault/screens/settings/app_icons.dart';
import 'package:vault/screens/settings/premium.dart';

import '../../consts/consts.dart';
import '../../provider/themeprovider.dart';
import '../../utils/utils.dart';
import '../../widgets/selectionbuttonwidget.dart';
import '../auth/chagepassword.dart';

class SettingsPage extends StatelessWidget {
  final int totalAlbums;
  final List<String> folderNames;

  const SettingsPage({Key? key, required this.totalAlbums, required this.folderNames}) : super(key: key);


  Future<bool> _saveImageToGallery(BuildContext context,
      Uint8List imageData, String imageName) async {
    try {
      print('Attempting to save image: $imageName');
      print('Image data length: ${imageData.length}');

      // Attempt to save the image
      final result = await ImageGallerySaver.saveImage(imageData, name: imageName);

      if (result['isSuccess'] == true) {
        print('Image $imageName saved to gallery successfully!');
        return true;
      } else {
        print('Failed to save image: ${result['error']}');
        return false;
      }
    } catch (error) {
      // Catch and log any errors that occurred during the save process
      print('Failed to save image $imageName: $error');
      return false;
    }
  }

  // Future<void> _exportAllImages(BuildContext context) async {
  //   try {
  //     // Calculate total number of images to export
  //     int totalImages = 0;
  //     for (final folderName in folderNames) {
  //       final Box box = await Hive.openBox(folderName);
  //       totalImages += box.length;
  //       await box.close();
  //     }
  //
  //     // Show progress dialog
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => ProgressDialog(
  //         message: 'Exporting files...',
  //         progress: exportedImages / totalImages,
  //       ),
  //     );
  //
  //     // Initialize variables to track progress
  //     int exportedImages = 0;
  //
  //     // Iterate over each folder name
  //     for (final folderName in folderNames) {
  //       // Open the Hive box for the current folder
  //       final Box box = await Hive.openBox(folderName);
  //
  //       // Get the keys (image names) from the box
  //       final List<dynamic> keys = box.keys.toList();
  //
  //       // Iterate over the keys (image names)
  //       for (final key in keys) {
  //         // Get the image data from the box
  //         final Uint8List imageData = box.get(key) as Uint8List;
  //         // Save the image to the gallery
  //         await _saveImageToGallery(context, imageData, key.toString());
  //
  //         // Update progress
  //         exportedImages++;
  //         // Update progress dialog
  //         Navigator.of(context).pop(); // Close previous dialog
  //         showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (context) => ProgressDialog(
  //             progress: exportedImages / totalImages,
  //             message: 'Exporting files...',
  //           ),
  //         );
  //       }
  //
  //       // Close the box after processing all images in the folder
  //       await box.close();
  //     }
  //
  //     // Hide the progress dialog and show a success message
  //     Navigator.of(context).pop(); // Hide the progress dialog
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('All files exported successfully!')),
  //     );
  //   } catch (error) {
  //     // Hide the progress dialog and show an error message
  //     Navigator.of(context).pop(); // Hide the progress dialog
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to export files: $error')),
  //     );
  //   }
  // }

  Future<void> _exportAllImages(BuildContext context) async {
    try {
      // Calculate total number of images to export
      int totalImages = 0;
      for (final folderName in folderNames) {
        final Box box = await Hive.openBox(folderName);
        totalImages += box.length;
        await box.close();
      }

      // Show initial progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          message: 'Exporting files...',
          progress: 0.0, // Start with 0 progress
        ),
      );

      // Initialize variables to track progress
      int exportedImages = 0;

      // Iterate over each folder name
      for (final folderName in folderNames) {
        // Open the Hive box for the current folder
        final Box box = await Hive.openBox(folderName);

        // Get the keys (image names) from the box
        final List<dynamic> keys = box.keys.toList();

        // Iterate over the keys (image names)
        for (final key in keys) {
          // Get the image data from the box
          final Uint8List imageData = box.get(key) as Uint8List;
          // Save the image to the gallery
          await _saveImageToGallery(context, imageData, key.toString());

          // Update progress
          exportedImages++;

          // Calculate progress
          double progress = totalImages == 0 ? 1.0 : exportedImages / totalImages;

          // Update progress dialog
          Navigator.of(context).pop(); // Close current dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ProgressDialog(
              progress: progress,
              message: 'Exporting files...',
            ),
          );
        }

        // Close the box after processing all images in the folder
        await box.close();
      }

      // Hide the progress dialog and show a success message
      Navigator.of(context).pop(); // Hide the progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All files exported successfully!')),
      );
    } catch (error) {
      print('Failed to export files: $error');
      // Hide the progress dialog and show an error message
      Navigator.of(context).pop(); // Hide the progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export files: $error')),
      );
    }
  }



  // Future<void> _exportAllFiles(BuildContext context) async {
  // Future<void> _exportAllFiles(BuildContext context) async {
  //   // Open the Hive box for each folder
  //   final List<String> folderNames = await Hive.box('Home').keys.cast<String>().toList();
  //
  //   // Get the path to the temporary directory
  //   final Directory directory = await getTemporaryDirectory();
  //
  //   // Define the path to the zip file
  //   final String zipFilePath = '${directory.path}/exported_files.zip';
  //
  //   // Create a zip file
  //   final File zipFile = File(zipFilePath);
  //   final ZipFileEncoder zipEncoder = ZipFileEncoder();
  //   zipEncoder.create(zipFilePath); // Start the zip creation
  //
  //   int currentFileIndex = 0;
  //   final int totalFiles = folderNames.length;
  //
  //   // Show progress dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => ProgressDialog(
  //       progress: currentFileIndex / totalFiles,
  //       message: 'Exporting files...',
  //     ),
  //   );
  //
  //   // Iterate over each folder and export its contents
  //   for (final String folderName in folderNames) {
  //     final Box box = await Hive.openBox(folderName);
  //     final List<dynamic> keys = box.keys.toList();
  //
  //     // Iterate over the files in the folder
  //     for (final dynamic key in keys) {
  //       final Uint8List imageData = box.get(key) as Uint8List;
  //       final String imageName = key.toString();
  //       final String tempFilePath = '${directory.path}/$imageName';
  //
  //       // Write image data to temporary file
  //       final File tempFile = File(tempFilePath);
  //       await tempFile.writeAsBytes(imageData);
  //
  //       // Add the temporary file to the zip file
  //       zipEncoder.addFile(tempFile, '$folderName/$imageName');
  //
  //       currentFileIndex++;
  //     }
  //     // Close the box for the current folder
  //     await box.close();
  //   }
  //
  //   // Close the zip file
  //   zipEncoder.close();
  //
  //   // Notify the user that the zip file has been saved
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Files exported to: $zipFilePath')),
  //   );
  // }

  // Future<void> _exportAllFiles(BuildContext context) async {
  //   try {
  //     // Get the path to the temporary directory
  //     final Directory directory = await getTemporaryDirectory();
  //
  //     // Define the path to the zip file
  //     final String zipFilePath = '${directory.path}/exported_files.zip';
  //
  //     // Create a zip file
  //     final File zipFile = File(zipFilePath);
  //     final ZipFileEncoder zipEncoder = ZipFileEncoder();
  //     zipEncoder.create(zipFilePath); // Start the zip creation
  //
  //     // Iterate over each folder and export its contents
  //     for (final String folderName in folderNames) {
  //       final Box box = await Hive.openBox(folderName);
  //       final List<dynamic> keys = box.keys.toList();
  //
  //       // Iterate over the files in the folder
  //       for (final dynamic key in keys) {
  //         final Uint8List imageData = box.get(key) as Uint8List;
  //         final String imageName = key.toString();
  //         final String tempFolderPath = '${directory.path}/$folderName';
  //         final String tempFilePath = '$tempFolderPath/$imageName';
  //
  //         // Create the temporary folder if it doesn't exist
  //         await Directory(tempFolderPath).create(recursive: true);
  //
  //         // Write image data to temporary file
  //         final File tempFile = File(tempFilePath);
  //         await tempFile.writeAsBytes(imageData);
  //
  //         // Add the temporary file to the zip file
  //         zipEncoder.addFile(tempFile, '$folderName/$imageName');
  //       }
  //
  //       // Close the box for the current folder
  //       await box.close();
  //     }
  //
  //     // Close the zip file
  //     zipEncoder.close();
  //
  //     print('Zip file created successfully at: $zipFilePath');
  //     Share.shareFiles([zipFilePath], text: 'Exported files');
  //   } catch (error) {
  //     print('Failed to create zip file: $error');
  //   }
  // }


  // Future<void> _exportAllFiles(BuildContext context) async {
  //   try {
  //     // Get the path to the temporary directory
  //     final Directory directory = await getTemporaryDirectory();
  //
  //     // Define the path to the zip file
  //     final String zipFilePath = '${directory.path}/exported_files.zip';
  //
  //     // Create a zip file
  //     final File zipFile = File(zipFilePath);
  //     final ZipFileEncoder zipEncoder = ZipFileEncoder();
  //     zipEncoder.create(zipFilePath); // Start the zip creation
  //
  //     // Initialize variables to track progress
  //     int exportedImages = 0;
  //
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => ProgressDialog(
  //         progress: 0, // Start with 0 progress
  //         message: 'Exporting files...',
  //       ),
  //     );
  //
  //     // Calculate total number of images to export
  //     int totalImages = 0;
  //     for (final folderName in folderNames) {
  //       final Box box = await Hive.openBox(folderName);
  //       totalImages += box.length;
  //       await box.close();
  //     }
  //
  //     // Show progress dialog
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => ProgressDialog(
  //         progress: 0, // Start with 0 progress
  //         message: 'Exporting files...',
  //       ),
  //     );
  //
  //     // Iterate over each folder and export its contents
  //     for (final String folderName in folderNames) {
  //       final Box box = await Hive.openBox(folderName);
  //       final List<dynamic> keys = box.keys.toList();
  //
  //       // Iterate over the files in the folder
  //       for (final dynamic key in keys) {
  //         final Uint8List imageData = box.get(key) as Uint8List;
  //         final String imageName = key.toString();
  //         final String tempFolderPath = '${directory.path}/$folderName';
  //         final String tempFilePath = '$tempFolderPath/$imageName';
  //
  //         // Create the temporary folder if it doesn't exist
  //         await Directory(tempFolderPath).create(recursive: true);
  //
  //         // Write image data to temporary file
  //         final File tempFile = File(tempFilePath);
  //         await tempFile.writeAsBytes(imageData);
  //
  //         // Add the temporary file to the zip file
  //         zipEncoder.addFile(tempFile, '$folderName/$imageName');
  //
  //         // Update progress
  //         exportedImages++;
  //         double progress = totalImages == 0 ? 0 : exportedImages / totalImages;
  //
  //         // Update progress dialog
  //         showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (context) => ProgressDialog(
  //             progress: progress,
  //             message: 'Exporting files...',
  //           ),
  //         );
  //       }
  //
  //       // Close the box for the current folder
  //       await box.close();
  //     }
  //
  //     // Close the zip file
  //     zipEncoder.close();
  //
  //     // Hide the progress dialog
  //     Navigator.of(context).pop();
  //
  //     // Notify the user that the zip file has been saved
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Files exported to: $zipFilePath')),
  //     );
  //
  //     // Share the zip file
  //     Share.shareFiles([zipFilePath], text: 'Exported files');
  //   } catch (error) {
  //     // Hide the progress dialog and show an error message
  //     Navigator.of(context).pop();
  //     print('Failed to export files: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to export files: $error')),
  //     );
  //   }
  // }



  Future<void> _exportAllFiles(BuildContext context) async {
    try {
      // Get the path to the temporary directory
      final Directory directory = await getTemporaryDirectory();

      // Define the path to the zip file
      final String zipFilePath = '${directory.path}/exported_files.zip';

      // Create a zip file
      final File zipFile = File(zipFilePath);
      final ZipFileEncoder zipEncoder = ZipFileEncoder();
      zipEncoder.create(zipFilePath); // Start the zip creation

      // Initialize variables to track progress
      int exportedImages = 0;

      // Calculate total number of images to export
      int totalImages = 0;
      for (final folderName in folderNames) {
        final Box box = await Hive.openBox(folderName);
        totalImages += box.length;
        await box.close();
      }

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          progress: 0, // Start with 0 progress
          message: 'Exporting files...',
        ),
      );

      // Iterate over each folder and export its contents
      for (final String folderName in folderNames) {
        final Box box = await Hive.openBox(folderName);
        final List<dynamic> keys = box.keys.toList();

        // Iterate over the files in the folder
        for (final dynamic key in keys) {
          final Uint8List imageData = box.get(key) as Uint8List;
          final String imageName = key.toString();
          final String tempFolderPath = '${directory.path}/$folderName';
          final String tempFilePath = '$tempFolderPath/$imageName';

          // Create the temporary folder if it doesn't exist
          await Directory(tempFolderPath).create(recursive: true);

          // Write image data to temporary file
          final File tempFile = File(tempFilePath);
          await tempFile.writeAsBytes(imageData);

          // Add the temporary file to the zip file
          zipEncoder.addFile(tempFile, '$folderName/$imageName');

          // Update progress
          exportedImages++;
          double progress = totalImages == 0 ? 0 : exportedImages / totalImages;

          // Update progress dialog
          Navigator.of(context).pop(); // Close existing dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ProgressDialog(
              progress: progress,
              message: 'Exporting files...',
            ),
          );
        }

        // Close the box for the current folder
        await box.close();
      }

      // Close the zip file
      zipEncoder.close();

      // Hide the progress dialog
      Navigator.of(context).pop();

      // Notify the user that the zip file has been saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Files exported to: $zipFilePath')),
      );

      final XFile xFile = XFile(zipFilePath);
      await Share.shareXFiles([xFile], subject: 'Exported files');
      // Share the zip file
      //Share.shareFiles([zipFilePath], text: 'Exported files');
    } catch (error) {
      // Hide the progress dialog and show an error message
      Navigator.of(context).pop();
      print('Failed to export files: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export files: $error')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
print('albums $totalAlbums $folderNames');
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        // Prevent default back button behavior
        return false;
      },
      child: Scaffold(
        //backgroundColor: Consts.BG_COLOR,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.07),
          child: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR,
            centerTitle: true,
            title: const Text('Setting',
              style: TextStyle(
              //color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'GilroyBold', // Apply Gilroy font family
            ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
              ),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02,),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                      vertical: size.height * 0.005
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Settings',
                        style: TextStyle(
                          //color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'GilroyBold', // Apply Gilroy font family
                        ),),
                    ),
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Language',
                    iconData: 'assets/settings/fi_8933942.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => languagesScreen(false),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'App Icon',
                    iconData: 'assets/settings/app-store (1) 1.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppIcons(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Export all Files',
                    iconData: 'assets/settings/download (1) 2.svg',
                    onTap: () async {

                      final userChoice = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Center(child: Text('Export Files')),
                          content: Text('Would you like to save the images to the gallery or download them as a zip file?'),
                          actions: [
                           Row(
                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                           children: [
                             TextButton(
                              onPressed: () {
                                // User chose to save images to the gallery
                                Navigator.of(context).pop('gallery');
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                minimumSize: MaterialStateProperty.all(Size(120, 40)), // Set button size
                                backgroundColor: MaterialStateProperty.all(
                                  Consts.COLOR
                                ), // Set background color
                              ),
                              child: Text('Save to Gallery',
                              style: TextStyle(
                                color: Colors.white
                              ),),
                            ),
                            TextButton(
                              onPressed: () {
                                // User chose to download the zip file
                                Navigator.of(context).pop('zip');
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                minimumSize: MaterialStateProperty.all(Size(120, 40)), // Set button size
                                backgroundColor: MaterialStateProperty.all(Consts.COLOR), // Set background color
                              ),
                              child: Text('Download Zip',
                              style: TextStyle(
                                color: Colors.white
                              ),),
                            ),])
                          ],
                        ),
                      );

                 // if (userChoice == 'gallery') {
                 //        String folderName =
                 //            "yourfolder"; // Specify the folder name
                 //        final box = await Hive.openBox(folderName);
                 //        final List<dynamic> keys = box.keys.toList();
                 //
                 //        bool allFilesSaved = true;
                 //        List<String> failedFiles = [];
                 //
                 //        for (var key in keys) {
                 //          final Uint8List imageData = box.get(key) as Uint8List;
                 //          final String imageName = key.toString();
                 //
                 //          // Attempt to save the image and check the result
                 //          final result = await _saveImageToGallery(
                 //              context, imageData, imageName);
                 //
                 //          if (!result) {
                 //            // Check for failed save operations
                 //            allFilesSaved = false;
                 //            failedFiles.add(imageName);
                 //          }
                 //        }
                 //
                 //
                 //        // Display the appropriate snack bar message based on whether all files were saved
                 //        if (allFilesSaved) {
                 //          ScaffoldMessenger.of(context).showSnackBar(
                 //            SnackBar(
                 //                content:
                 //                    Text('All files exported successfully!')),
                 //          );
                 //        } else {
                 //          ScaffoldMessenger.of(context).showSnackBar(
                 //            SnackBar(
                 //                content: Text(
                 //                    'Some files failed to export: ${failedFiles.join(", ")}')),
                 //          );
                 //        }
                 //      }
                      if (userChoice == 'gallery'){
                        await _exportAllImages(context);
                      }
                 else if (userChoice == 'zip') {
                   // Download zip file
                   await _exportAllFiles(context);
                       }
                    },
                  ),


                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Security',
                    iconData: 'assets/settings/shield 1.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Theme',
                    iconData: 'assets/settings/theme 1.svg',
                    onTap: () {
                      Utils(context).showCustomDialog(
                        child: _themetileWidget(
                          context: context,
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: size.height * 0.01
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Membership',
                        style: TextStyle(
                          //color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'GilroyBold', // Apply Gilroy font family
                        ),),
                    ),
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Restore Purchase',
                    iconData: 'assets/settings/rotate 1.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: size.height * 0.01
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Others',
                        style: TextStyle(
                          //color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'GilroyBold', // Apply Gilroy font family
                        ),),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Share this app',
                    iconData: 'assets/settings/share (1) 1.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Privacy Policy',
                    iconData: 'assets/settings/padlock 3.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Rate our app',
                    iconData: 'assets/settings/star 1.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'App Version',
                    iconData: 'assets/settings/version 1.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: 'Contact Us',
                    iconData: 'assets/settings/email 1.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildListtile({
    required BuildContext context, // Add BuildContext context
    required String iconData,
    required String tiletitle,
    required Function onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
        onTap: () {
          onTap();
        },
        child: ListTile(
          leading: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Theme.of(context).brightness == Brightness.light
                  ? Colors.black // Color for light theme
                  : Colors.white, // Color for dark theme
              BlendMode.srcIn,
            ),
            child: SvgPicture.asset(iconData),
          ),
          title: Text(tiletitle),
        ),
      ),
    );
  }

  _themetileWidget({required BuildContext context}) {
    return Consumer<ThemeProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Theme',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectionButtonWidget(
                  buttontitle: 'System Theme',
                  iconCondition: provider.themeMode == ThemeMode.system,
                  ontap: () {
                    provider.themeMode = ThemeMode.system;
                  },
                ),
                const Divider(
                  height: 0,
                ),
                SelectionButtonWidget(
                  iconCondition: provider.themeMode == ThemeMode.light,
                  buttontitle: 'Light Theme',
                  ontap: () {
                    provider.themeMode = ThemeMode.light;
                  },
                ),
                const Divider(
                  height: 0,
                ),
                SelectionButtonWidget(
                  iconCondition: provider.themeMode == ThemeMode.dark,
                  buttontitle: 'Dark Theme',
                  ontap: () {
                    provider.themeMode = ThemeMode.dark;
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class ProgressDialog extends StatefulWidget {
  final double progress;
  final String message;

  ProgressDialog({required this.progress, required this.message});

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  // Function to handle navigation when progress reaches 100%
  void _handleNavigation() {
    if (widget.progress == 1.0) {
      // Close the current dialog
      Navigator.of(context).pop();

      // Show the continue dialog asynchronously after the build is complete
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Column(
              children: [
                SvgPicture.asset('assets/Group 21149.svg'),
                SizedBox( height: 2,),
                Text('Exported Successfully!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Add your cancel logic here
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all(Size(285, 44)), // Set button size
                  backgroundColor: MaterialStateProperty.all(
                      Consts.COLOR
                  ), // Set background color
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                  ),
                ),
              ),
            ],
          ),
        );
      }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => SettingsPage( totalAlbums: , // Pass the actual value received in the settings screen
        //       folderNames: folderNames, ),
        //   ),
        // );
        // Prevent default back button behavior
        return false;
      },
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: widget.progress,
                  ),
                ),
                Text(
                  '${(widget.progress * 100).toStringAsFixed(0)}%', // Format percentage as an integer
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(widget.message),
          ],
        ),
      ),
    );
  }
}

