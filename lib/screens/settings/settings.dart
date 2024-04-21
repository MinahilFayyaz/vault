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
import 'package:vault/screens/settings/app_icons.dart';
import 'package:vault/screens/settings/premium.dart';

import '../../consts/consts.dart';
import '../../provider/themeprovider.dart';
import '../../utils/utils.dart';
import '../../widgets/selectionbuttonwidget.dart';
import '../auth/chagepassword.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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

  Future<void> _exportAllFiles(BuildContext context) async {
    // Open the Hive box
    final box = await Hive.openBox('Home');
    final List<dynamic> keys = box.keys.toList();

    // Get the path to the temporary directory
    final directory = await getTemporaryDirectory();

    // Define the path to the zip file
    final zipFilePath = '${directory.path}/exported_files.zip';

    // Create a zip file from the archive
    final zipFile = File(zipFilePath);
    final zipEncoder = ZipFileEncoder();
    zipEncoder.create(zipFilePath);  // Start the zip creation

    int currentFileIndex = 0;
    final totalFiles = keys.length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        progress: currentFileIndex / totalFiles,
        message: 'Exporting files...',
      ),
    );

    // Iterate over the keys in the Hive box
    for (var key in keys) {
      // Get the image data from the box
      final Uint8List imageData = box.get(key) as Uint8List;
      final String imageName = key.toString();

      // Create a temporary file to add to the zip
      final tempFilePath = '${directory.path}/$imageName';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(imageData);

      // Add the temporary file to the zip file
      zipEncoder.addFile(tempFile, imageName);

      currentFileIndex++;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          progress: currentFileIndex / totalFiles,
          message: 'Exporting files...',
        ),
      );
      // Optionally, delete the temporary file after adding to zip
      //await tempFile.delete();
  }

    // Close the zip file
    zipEncoder.close();

    print('Files exported to: $zipFilePath');
    // Notify the user that the zip file has been saved
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Files exported to: $zipFilePath')),
    );

    // Optionally, you can provide a way for the user to directly download the zip file from the temporary directory
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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

               if (userChoice == 'gallery') {
                      String folderName =
                          "yourfolder"; // Specify the folder name
                      final box = await Hive.openBox(folderName);
                      final List<dynamic> keys = box.keys.toList();

                      bool allFilesSaved = true;
                      List<String> failedFiles = [];

                      for (var key in keys) {
                        final Uint8List imageData = box.get(key) as Uint8List;
                        final String imageName = key.toString();

                        // Attempt to save the image and check the result
                        final result = await _saveImageToGallery(
                            context, imageData, imageName);

                        if (!result) {
                          // Check for failed save operations
                          allFilesSaved = false;
                          failedFiles.add(imageName);
                        }
                      }


                      // Display the appropriate snack bar message based on whether all files were saved
                      if (allFilesSaved) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('All files exported successfully!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Some files failed to export: ${failedFiles.join(", ")}')),
                        );
                      }
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

class ProgressDialog extends StatelessWidget {
  final double progress;
  final String message;

  ProgressDialog({required this.progress, required this.message});

  @override
  Widget build(BuildContext context) {
    // Close the dialog if progress reaches or exceeds 1.0 (100%)
    if (progress >= 1.0) {
      Navigator.of(context).pop(); // Close the dialog
    }

    return AlertDialog(
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
                  value: progress,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%', // Format percentage as an integer
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}


