import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/screens/settings/premium.dart';

import '../consts/consts.dart';
import '../utils/utils.dart';
import 'album.dart';
import 'generatorpage.dart';
import 'settings/settings.dart';
import 'vault/vaultpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  List<String> folderNames = []; // List to hold folder names
  List<File> selectedImages = [];
  List<String> selectedImagePaths = [];
  //List<File> folderContents = []; // Define and initialize folderContents list
  Map<String, List<File>> folderContents = {};

  @override
  void initState() {
    super.initState();
    // Load folder names from shared preferences when the widget initializes
    _loadFolderNames();
  }

  void _copyImageToFolder(File image, String folderName) {
    print('Copying image to folder: $folderName');

    setState(() {
      // Add the selected image to the specified folder
      //folderContents.add(image);

      if (!folderContents.containsKey(folderName)) {
        folderContents[folderName] = [];
      }
      folderContents[folderName]!.add(image);


      print('Image added to folderContents list');


      // Navigate to the FolderContentsPage of the selected folder
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderContentsPage(
            folderName: folderName,
            folderContents: folderContents[folderName] != null ? folderContents[folderName]! : [],
            updateFolderContents: (updatedContents) => _updateFolderContents(folderName, updatedContents),
          ),

        ),
      );


      print('Navigated to FolderContentsPage');
    });
  }

  void _updateFolderContents(String folderName, List<File> updatedContents) {
    setState(() {
      // Update the folder contents for the specified folder name
      folderContents[folderName] = updatedContents;
    });
  }



  // Method to load folder names from shared preferences
  Future<void> _loadFolderNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print('Loading folder names and selected image paths');
    List<String>? savedFolderNames = prefs.getStringList('folderNames');
    //List<String>? savedImagePaths = prefs.getStringList('selectedImagePaths');

    var box = await Hive.openBox('selected_images');
    List<String>? savedImagePaths = box.get('images');
    setState(() {
      // Check if savedFolderNames is null or empty, if so, add default folders
      if (savedFolderNames == null || savedFolderNames.isEmpty) {
        folderNames.addAll(['Home', 'WhatsApp']);
        _saveFolderNames();

        print('Loading folder set state names and selected image paths');// Save default folders to shared preferences
      } else {
        folderNames = savedFolderNames;
      }
      if (savedImagePaths != null) {
        selectedImagePaths = savedImagePaths;
        // Load selected images from their paths
        selectedImages = selectedImagePaths.map((path) => File(path)).toList();
      }
    });
  }

  // Method to save folder names to shared preferences
  Future<void> _saveFolderNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> imagePaths = selectedImages.map((image) => image.path).toList();
    print('Image paths to save: $imagePaths');
    await prefs.setStringList('folderNames', folderNames);
    await prefs.setStringList('selectedImagePaths', imagePaths);
    var box = await Hive.openBox('selected_images');
    await box.put('images', imagePaths);
  }

  void _navigateToFolderContents(String folderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderContentsPage(
          folderName: folderName,
          folderContents: folderContents[folderName] != null ? folderContents[folderName]! : [],
          updateFolderContents: (updatedContents) => _updateFolderContents(folderName, updatedContents),
        ),

      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) => Utils(context).onWillPop(),
      child: Scaffold(
        //backgroundColor: Consts.BG_COLOR,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.07),
          child: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR,
            leading: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)
                  => SettingsPage(
                      totalAlbums: folderNames.length, folderNames: folderNames
                  )));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Color(0xFFF5F5F5) // Color for light theme
                        : Color(0xFF585956),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Icon(
                    Icons.settings, // You can use any icon here
                    size: screenWidth * 0.06, // Adjust the size as needed
                    //color: Colors.white, // Icon color
                  ),
                ),
              ),
            ),
            title: Text(
              'LOCKER',
              style: TextStyle(
                //color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'GilroyBold', // Apply Gilroy font family
              ),
            ),
            actions: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)
                  => PremiumScreen()));
                },
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Container(
                    height: screenHeight * 0.05,
                    width: screenHeight * 0.05,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Color(0xFFF5F5F5) // Color for light theme
                          : Color(0xFF585956),
                      borderRadius: BorderRadius.circular(screenHeight * 0.01),
                    ),
                        child: Theme.of(context).brightness == Brightness.light
                        ? SvgPicture.asset('assets/premium (3).svg')
                            : ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn),
                          child: SvgPicture.asset('assets/premium (3).svg'),
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Text(
                          'Albums',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w400,
                            //«color: Colors.white,
                            fontFamily: 'Gilroy', // Apply Gilroy font family
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
                          '(${folderNames.length} Albums)',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF363C54),
                            fontFamily: 'Gilroy', // Apply Gilroy font family
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      spacing: screenWidth * 0.02, // Add spacing between the containers
                      runSpacing: screenHeight * 0.01, // Add spacing between the rows
                      children: [
                        GestureDetector(
                          onTap: () async {
                            String? folderName = await _showAddFolderDialog(context);
                            if (folderName != null && folderName.isNotEmpty) {
                              setState(() {
                                folderNames.add(folderName); // Add the new folder to the list
                                _saveFolderNames();
                              });
                            }
                            //_navigateToFolderContents(folderName!);
                          },
                          child: Container(
                            height: screenHeight * 0.13,
                            width: screenWidth * 0.29,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Color(0xFFF5F5F5) // Color for light theme
                                  : Consts.FG_COLOR,
                              borderRadius: BorderRadius.circular(screenHeight * 0.02),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 30,
                            ),
                          ),
                        ),
                        // Dynamically generate containers for each folder name
                        for (String folderName in folderNames)
                          GestureDetector(
                            onTap: (){
                              _navigateToFolderContents(folderName);
                            },
                            child: Container(
                              height: screenHeight * 0.13,
                              width: screenWidth * 0.29,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Color(0xFFF5F5F5) // Color for light theme
                                    : Consts.FG_COLOR,
                                borderRadius: BorderRadius.circular(screenHeight * 0.02),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset('assets/46 Open File, Document, Folder.svg'),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(
                                      folderName,
                                      style: TextStyle(
                                        //color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Gilroy', // Apply Gilroy font family
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Text(
                          'Media',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w400,
                            //color: Colors.white,
                            fontFamily: 'Gilroy', // Apply Gilroy font family
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
                          '(${selectedImages.length} Media)',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF363C54),
                            fontFamily: 'Gilroy', // Apply Gilroy font family
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      spacing: screenWidth * 0.02, // Add spacing between the containers
                      runSpacing: screenHeight * 0.01, // Add spacing between the rows
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // Open the gallery
                            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                // Add the picked image to the list of selected images
                                selectedImages.add(File(pickedFile.path));
                                _saveFolderNames();
                              });
                            }
                          },
                          child: Container(
                            height: screenHeight * 0.13,
                            width: screenWidth * 0.29,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Color(0xFFF5F5F5) // Color for light theme
                                  : Consts.FG_COLOR,
                              borderRadius: BorderRadius.circular(screenHeight * 0.02),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 30,
                            ),
                          ),
                        ),
                        // Dynamically generate containers for each selected image
                        for (File image in selectedImages)
                          GestureDetector(
                            onTap: () {
                              _showImageOptionsBottomSheet(context, image);
                            },
                            child: Container(
                              height: screenHeight * 0.13,
                              width: screenWidth * 0.29,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(screenHeight * 0.02),
                                child: Image.file(
                                  image,
                                  fit: BoxFit.cover, // Fit the image to cover the container
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _showAlbumSelectionDialog(BuildContext context, File image) async {
    return showModalBottomSheet(
      backgroundColor: Theme.of(context).brightness == Brightness.light
        ? Color(0xFFFFFFFF) // Color for light theme
        : Consts.FG_COLOR,
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: SvgPicture.asset('assets/Home Indicator.svg')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add to Album',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        //color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 14,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  spacing: screenWidth * 0.02,
                  runSpacing: screenHeight * 0.01,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String? folderName = await _showAddFolderDialog(context);
                        if (folderName != null && folderName.isNotEmpty) {
                          setState(() {
                            folderNames.add(folderName);
                            _saveFolderNames();
                            // Copy the image to the selected folder
                            _copyImageToFolder(image, folderName);
                          });
                        }
                      },
                      child: Container(
                        height: screenHeight * 0.13,
                        width: screenWidth * 0.29,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Color(0xFFE8E8E8) // Color for light theme
                              : Consts.BG_COLOR,
                          borderRadius: BorderRadius.circular(screenHeight * 0.02),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                    ),
                    // Dynamically generate containers for each folder name
                    for (String folderName in folderNames)
                      GestureDetector(
                        onTap: () {
                          // Copy the image to the selected folder
                          _copyImageToFolder(image, folderName);
                          // Navigate to the folder contents page
                          //_navigateToFolderContents(folderName);
                        },
                        child: Container(
                          height: screenHeight * 0.13,
                          width: screenWidth * 0.29,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Color(0xFFE8E8E8) // Color for light theme
                                : Consts.BG_COLOR,
                            borderRadius: BorderRadius.circular(screenHeight * 0.02),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/46 Open File, Document, Folder.svg'),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  folderName,
                                  style: TextStyle(
                                    //color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Gilroy',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImageOptionsBottomSheet(BuildContext context, File image) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final double paddingValue = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.06;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make the background transparent
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR, // Set background color
            borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05)), // Add rounded corners at the top
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, paddingValue * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: SvgPicture.asset('assets/image-gallery 1.svg')
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      'Add to Album',
                      style: TextStyle(
                        //color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Add logic to add image to album
                    _showAlbumSelectionDialog(context, image);
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: SvgPicture.asset('assets/download (1) 1.svg')
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      'Save to Photos',
                      style: TextStyle(
                        //color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () async {
                    // Save image to photos
                    final result = await saveImageToGallery(image);
                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Image saved to photos'),
                        duration: Duration(seconds: 2),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to save image to photos'),
                        duration: Duration(seconds: 2),
                      ));
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: SvgPicture.asset('assets/delete 1.svg'),
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      'Delete Media',
                      style: TextStyle(
                        //color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Add logic to delete media
                    // Remove the selected image from the list
                    setState(() {
                      selectedImages.remove(image);
                      _saveFolderNames(); // Update shared preferences
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<bool> saveImageToGallery(File image) async {
    try {
      // Save the image to the device's photo gallery
      final result = await ImageGallerySaver.saveFile(image.path);
      return result['isSuccess'];
    } catch (e) {
      print('Error saving image to gallery: $e');
      return false;
    }
  }


  // Method to show the add folder dialog
  Future<String?> _showAddFolderDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: Consts.FG_COLOR,
          title: Center(child: Text('Create New Album',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700
            ),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Enter a name for this album',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500
                ),
              )),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Consts.COLOR), // Border around the TextField
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    //color: Consts.BG_COLOR
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none, // Remove default border
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
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
                minimumSize: MaterialStateProperty.all(Size(120, 40)), // Set button size
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).brightness == Brightness.light
                      ? Color(0xFFE8E8E8) // Color for light theme
                      : Consts.BG_COLOR,
                ), // Set background color
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
            ),
            SizedBox(width: 5,),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Consts.COLOR),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(Size(120, 40)), // Set button size
                backgroundColor: MaterialStateProperty.all(Consts.COLOR), // Set background color
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

}
