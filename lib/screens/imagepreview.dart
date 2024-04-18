import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vault/screens/album.dart';
import 'package:vault/screens/homepage.dart';
import '../consts/consts.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  final String imageName;
  final Function(File)? onImageRemoved;
  final String? folderName;// Callback function

  const ImagePreviewScreen({
    Key? key,
    required this.imageFile,
    required this.imageName,
    this.onImageRemoved,
    required this.folderName,
  }) : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get the file name with extension
    String fileNameWithExtension = widget.imageName.split('/').last;

    // Get the file name without extension
    String fileName = fileNameWithExtension.split('.').first;

    // Get the file extension
    String fileExtension = fileNameWithExtension.split('.').last;

    // Shorten the file name if it's too long
    String shortFileName = fileName.length > 20
        ? fileName.substring(0, 10) + '...'
        : fileName;

    // Combine the short file name with the file extension
    String shortImageName = '$shortFileName.$fileExtension';

    return Scaffold(
      backgroundColor: Consts.BG_COLOR,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.07),
        child: AppBar(
          backgroundColor: Consts.FG_COLOR,
          title: Text(
            shortImageName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontFamily: 'GilroyBold',
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                // Handle the info icon tap event
              },
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Icon(
                  Icons.info_outline,
                  size: screenWidth * 0.07,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Image.file(widget.imageFile),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
            // Adjust the fontSize property to change the label size
            bodyMedium: TextStyle(fontSize: 8),
          ),
        ),
        child: Container(
          height: 120,
          child: BottomNavigationBar(
            backgroundColor: Consts.FG_COLOR,
            showUnselectedLabels: true,
            unselectedItemColor: Colors.white,
            selectedItemColor: Consts.COLOR,
            unselectedFontSize: 11,
            selectedFontSize: 11,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 0 ? Consts.COLOR : Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: SvgPicture.asset(
                      'assets/share (1) 2.svg',
                    ),
                  ),
                ),
                label: 'Share',
                backgroundColor: Consts.FG_COLOR,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 1 ? Consts.COLOR : Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: SvgPicture.asset(
                      'assets/Frame.svg',
                    ),
                  ),
                ),
                label: 'Unlock',
                backgroundColor: Consts.FG_COLOR,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 2 ? Consts.COLOR : Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: SvgPicture.asset(
                      'assets/delete 1.svg',
                    ),
                  ),
                ),
                label: 'Delete',
                backgroundColor: Consts.FG_COLOR,
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (_selectedIndex == 1) {
                  _handleUnlockTap();
                } else if (_selectedIndex == 2) {
                  _handleDeleteTap();
                }
              });
            },
          ),
        ),
      ),
    );
  }

//   void _handleUnlockTap() async {
//     // Refer to widget.imageFile instead of imageFile
//     widget.onImageRemoved?.call(widget.imageFile);
//
//     // Return to the previous screen after deletion
// Navigator.push(context,
//     MaterialPageRoute(builder: (context) =>
//         HomePage()));
//     print('Attempting to unlock image file at path: ${widget.imageFile.path}');
//
//     // Verify file existence
//     final fileExists = await widget.imageFile.exists();
//     print('Does the file exist? $fileExists');
//
//     if (!fileExists) {
//       print('The image file does not exist at path: ${widget.imageFile.path}');
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('The image file does not exist at the specified path.'))
//       );
//       return;
//     }
//
//     // Continue with the rest of the method
//     // ...
//   }


  void _handleUnlockTap() async {
    if (_selectedIndex == 1) {
      // Check if the image file exists before attempting to delete
      bool fileExists = await widget.imageFile.exists();
      print('Does the file exist? $fileExists');

      if (!fileExists) {
        print('The image file does not exist at path: ${widget.imageFile.path}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The image file does not exist.'))
        );
        return; // Exit since file doesn't exist
      }

      // Attempt to delete the image file
      try {
        // Delete the file
        await widget.imageFile.delete();

        // Open the Hive box
        final box = await Hive.openBox(widget.folderName ?? 'defaultFolderName'); // Provide a default folder name if widget.folderName is null

        // Find the key associated with the file path
        String? keyToRemove;
        for (var key in box.keys) {
          final value = box.get(key);
          final filePath = '${(await getTemporaryDirectory()).path}/$key.png';
          if (value is Uint8List && filePath == widget.imageFile.path) {
            keyToRemove = key;
            break;
          }
        }

        // Delete the associated key from the Hive box
        if (keyToRemove != null) {
          await box.delete(keyToRemove);
        }

        // If there is a callback function to notify the parent page, call it
        if (widget.onImageRemoved != null) {
          widget.onImageRemoved!(widget.imageFile);
        }

        // Notify the user that the image has been deleted
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image unlocked successfully.'))
        );
        Navigator.push(context,
    MaterialPageRoute(builder: (context) =>
        HomePage()));
      } catch (e) {
        // Handle any errors that may occur during the deletion
        print('Error deleting image file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting image file.'))
        );
      }
    }
  }

  void _handleDeleteTap() async {
    if (_selectedIndex == 2) {
      // Check if the image file exists before attempting to delete
      bool fileExists = await widget.imageFile.exists();
      print('Does the file exist? $fileExists');

      if (!fileExists) {
        print('The image file does not exist at path: ${widget.imageFile.path}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The image file does not exist.'))
        );
        return; // Exit since file doesn't exist
      }

      // Attempt to delete the image file
      try {
        // Delete the file
        await widget.imageFile.delete();

        // Open the Hive box
        final box = await Hive.openBox(widget.folderName ?? 'defaultFolderName'); // Provide a default folder name if widget.folderName is null

        // Find the key associated with the file path
        String? keyToRemove;
        for (var key in box.keys) {
          final value = box.get(key);
          final filePath = '${(await getTemporaryDirectory()).path}/$key.png';
          if (value is Uint8List && filePath == widget.imageFile.path) {
            keyToRemove = key;
            break;
          }
        }

        // Delete the associated key from the Hive box
        if (keyToRemove != null) {
          await box.delete(keyToRemove);
        }

        // If there is a callback function to notify the parent page, call it
        if (widget.onImageRemoved != null) {
          widget.onImageRemoved!(widget.imageFile);
        }

        // Notify the user that the image has been deleted
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image unlocked successfully.'))
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                HomePage()));
      } catch (e) {
        // Handle any errors that may occur during the deletion
        print('Error deleting image file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting image file.'))
        );
      }
    }
  }

}
