import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/screens/gallery.dart';
import 'package:vault/screens/settings/premium.dart';

import '../consts/consts.dart';
import '../permission.dart';
import '../utils/utils.dart';
import 'album.dart';
import 'settings/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> folderNames = []; // List to hold folder names
  List<File> selectedImages = [];
  List<String> selectedImagePaths = [];

  //List<File> folderContents = []; // Define and initialize folderContents list
  Map<String, List<File>> folderContents = {};

  void _copyImageToFolder(File image, String folderName) {
    setState(() {
      if (!folderContents.containsKey(folderName)) {
        folderContents[folderName] = [];
      }
      folderContents[folderName]!.add(image);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderContentsPage(
            folderName: folderName,
            folderContents: folderContents[folderName] != null
                ? folderContents[folderName]!
                : [],
            updateFolderContents: (updatedContents) =>
                _updateFolderContents(folderName, updatedContents),
          ),
        ),
      );
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
    List<String>? savedImagePaths = box.get('images')?.cast<String>();
    setState(() {
      // Check if savedFolderNames is null or empty, if so, add default folders
      if (savedFolderNames == null || savedFolderNames.isEmpty) {
        folderNames.addAll(['Home', 'WhatsApp']);
        _saveFolderNames();

        print(
            'Loading folder set state names and selected image paths'); // Save default folders to shared preferences
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
    List<String> imagePaths =
    selectedImages.map((image) => image.path).toList();
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
          isFirstAddButtonClick: isFirstAddButtonClick,
          folderContents: folderContents[folderName] != null
              ? folderContents[folderName]!
              : [],
          updateFolderContents: (updatedContents) =>
              _updateFolderContents(folderName, updatedContents),
        ),
      ),
    );
  }

  bool isFirstAddButtonClick = true;

// Method to check if it's the app's first launch
  Future<bool> isFirstAppLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      // Set the flag to indicate that it's not the first launch anymore
      prefs.setBool('isFirstLaunch', false);
    }
    return isFirstLaunch;
  }


  @override
  void initState() {
    super.initState();
    // Load folder names from shared preferences when the widget initializes
    _loadFolderNames();
    isFirstAppLaunch().then((isFirstLaunch) {
      setState(() {
        isFirstAddButtonClick = isFirstLaunch;
      });
    });
    _saveIsFirstAddButtonClick(isFirstAddButtonClick);
  }

  Future<void> _saveIsFirstAddButtonClick(bool isFirstButtonClick) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstAddButtonClick', isFirstAddButtonClick);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'HomeScreen');

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
                  FirebaseAnalytics.instance.logEvent(
                    name: 'home_settings_clicked',
                    parameters: <String, dynamic>{
                      'activity': 'Navigating to Settings',
                      'action': 'Button clicked',
                    },
                  );
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
              //AppLocalizations.of(context)!.share,
              AppLocalizations.of(context)!.locker,
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
                  FirebaseAnalytics.instance.logEvent(
                    name: 'home_premium_clicked',
                    parameters: <String, dynamic>{
                      'activity': 'Navigating to Premium',
                      'action': 'Button clicked',
                    },
                  );
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
                    child: SvgPicture.asset('assets/premium (3).svg',),
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
                          AppLocalizations.of(context)!.albums,
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
                          '(${folderNames.length} ' + AppLocalizations.of(context)!.albums +")",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF363C54),
                            fontFamily: 'Gilroy', // Apply Gilroy font family
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        spacing: screenWidth * 0.02,
                        // Add spacing between the containers
                        runSpacing: screenHeight * 0.01,
                        // Add spacing between the rows
                        children: [
                          GestureDetector(
                            onTap: () async {
                              String? folderName =
                              await _showAddFolderDialog(context);
                              if (folderName != null && folderName.isNotEmpty) {
                                setState(() {
                                  folderNames.add(
                                      folderName); // Add the new folder to the list
                                  _saveFolderNames();
                                });
                              }
                              FirebaseAnalytics.instance.logEvent(
                                name: 'home_new_album_added',
                                parameters: <String, dynamic>{
                                  'activity': 'Navigating to new album dialogue',
                                  'action': 'Button clicked',
                                },
                              );
                            },
                            child: Container(
                              height: screenHeight * 0.13,
                              width: screenWidth * 0.29,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                    Brightness.light
                                    ? Color(0xFFF5F5F5) // Color for light theme
                                    : Consts.FG_COLOR,
                                borderRadius:
                                BorderRadius.circular(screenHeight * 0.02),
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
                                _navigateToFolderContents(folderName);
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'home_album_clicked',
                                  parameters: <String, dynamic>{
                                    'activity': 'Navigating to album',
                                    'action': 'Album clicked',
                                  },
                                );
                              },
                              child: Container(
                                height: screenHeight * 0.13,
                                width: screenWidth * 0.29,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                      Brightness.light
                                      ? Color(0xFFF5F5F5) // Color for light theme
                                      : Consts.FG_COLOR,
                                  borderRadius:
                                  BorderRadius.circular(screenHeight * 0.02),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                          'assets/46 Open File, Document, Folder.svg'),
                                      SizedBox(height: screenHeight * 0.01),
                                      Text(
                                        folderName,
                                        style: TextStyle(
                                          //color: Colors.white,
                                          fontSize: 12,
                                          fontFamily:
                                          'Gilroy', // Apply Gilroy font family
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Text(
                        AppLocalizations.of(context)!.media,
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
                          '(${selectedImages.length} ' +AppLocalizations.of(context)!.media +")",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF363C54),
                            fontFamily: 'Gilroy', // Apply Gilroy font family
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        spacing: screenWidth * 0.02,
                        // Add spacing between the containers
                        runSpacing: screenHeight * 0.01,
                        // Add spacing between the rows
                        children: [
                          GestureDetector(
                            onTap: () async {
                              print('isFirstAddButtonClick : $isFirstAddButtonClick');
                              // Check if it's the first launch and if the "Add" button is clicked before opening any album
                              if (await isFirstAppLaunch() && isFirstAddButtonClick) {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                bool hasRequestedPermission = prefs.getBool('hasRequestedPermission') ?? false;

                                if (!hasRequestedPermission) {
                                  // Set the flag to indicate that permission has been requested
                                  prefs.setBool('hasRequestedPermission', true);

                                  // Show the permission screen before accessing the image picker
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Permission(folderName: ''),
                                    ),
                                  );
                                  setState(() {
                                    isFirstAddButtonClick = false;
                                  });
                                  _saveIsFirstAddButtonClick(isFirstAddButtonClick);
                                  return; // Return to avoid opening the image picker immediately
                                }
                              }

                              final pickedFiles =
                              await ImagePicker().pickMultipleMedia();
                              for (final pickedFile in pickedFiles) {
                                selectedImages.add(File(pickedFile.path));
                              }
                              setState(() {
                                _saveFolderNames();
                              });

                              FirebaseAnalytics.instance.logEvent(
                                name: 'home_image_picker_from_gallery_clicked',
                                parameters: <String, dynamic>{
                                  'activity': 'Navigating to Gallery',
                                  'action': 'Add Button clicked',
                                },
                              );
                            },
                            child: Container(
                              height: screenHeight * 0.13,
                              width: screenWidth * 0.29,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                    Brightness.light
                                    ? Color(0xFFF5F5F5) // Color for light theme
                                    : Consts.FG_COLOR,
                                borderRadius:
                                BorderRadius.circular(screenHeight * 0.02),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ),
                          ),
                          // Dynamically generate containers for each selected image
                          // for (File image in selectedImages)
                          ...List.generate(selectedImages.length, (index) {
                            String extension = selectedImages[index]
                                .path
                                .split('.')
                                .last
                                .toLowerCase();
                            if (extension == 'mp4' || extension == 'mov') {
                              // It's a video file

                              return Container(
                                height: screenHeight * 0.13,
                                width: screenWidth * 0.29,
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(screenHeight * 0.02),
                                  child: FutureBuilder<Uint8List?>(
                                    future: GalleryService.generateVideoThumbnail(
                                        selectedImages[index].path),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          color: Colors.grey,
                                        );
                                      } else if (snapshot.hasData) {
                                        return GestureDetector(
                                          onTap: () {
                                            _showImageOptionsBottomSheet(
                                                context, selectedImages[index]);
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            fit: StackFit.loose,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(12),
                                                      child: Image.memory(
                                                        snapshot.data!,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  _showImageOptionsBottomSheet(
                                      context, selectedImages[index]);
                                },
                                child: Container(
                                  height: screenHeight * 0.13,
                                  width: screenWidth * 0.29,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.02),
                                    child: Image.file(
                                      selectedImages[index],
                                      fit: BoxFit
                                          .cover, // Fit the image to cover the container
                                    ),
                                  ),
                                ),
                              );
                            }
                          }).toList().reversed,
                        ],
                      ),
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

  Future<void> _showAlbumSelectionDialog(
      BuildContext context, File image) async {
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
                Center(child:
                Theme.of(context).brightness == Brightness.light
                    ? ColorFiltered(colorFilter: ColorFilter.mode(
                    Colors.black, BlendMode.srcIn),
                    child :  SvgPicture.asset('assets/Home Indicator.svg')
                )// Color for light theme
                    :       SvgPicture.asset('assets/Home Indicator.svg')
                ),
                SizedBox(height: screenHeight * 0.01,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      AppLocalizations.of(context)!.addToAlbum,
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                          AppLocalizations.of(context)!.cancel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Color(0xFF666666)// Color for light theme
                                : Color(0xFF999999),
                            fontSize: 14,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w700,
                          ),
                        )
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: screenWidth * 0.02,
                    runSpacing: screenHeight * 0.01,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          String? folderName =
                          await _showAddFolderDialog(context);
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
                            color:
                            Theme.of(context).brightness == Brightness.light
                                ? Color(0xFFE8E8E8) // Color for light theme
                                : Consts.BG_COLOR,
                            borderRadius:
                            BorderRadius.circular(screenHeight * 0.02),
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
                              color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Color(0xFFE8E8E8) // Color for light theme
                                  : Consts.BG_COLOR,
                              borderRadius:
                              BorderRadius.circular(screenHeight * 0.02),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                      'assets/46 Open File, Document, Folder.svg'),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImageOptionsBottomSheet(
      BuildContext context, File image) async {
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
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                    screenWidth * 0.05)), // Add rounded corners at the top
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
                    child:Theme.of(context).brightness == Brightness.light
                        ? ColorFiltered(colorFilter: ColorFilter.mode(
                        Colors.black, BlendMode.srcIn),
                        child :  SvgPicture.asset('assets/image-gallery 1.svg')
                    )// Color for light theme
                        :       SvgPicture.asset('assets/image-gallery 1.svg'),

                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      AppLocalizations.of(context)!.addToAlbum,
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
                      child: Theme.of(context).brightness == Brightness.light
                          ? ColorFiltered(colorFilter: ColorFilter.mode(
                          Colors.black, BlendMode.srcIn),
                          child :  SvgPicture.asset('assets/download (1) 1.svg')
                      )
                          : SvgPicture.asset('assets/download (1) 1.svg')
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      AppLocalizations.of(context)!.saveToPhoto,
                      style: TextStyle(
                        //color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () async {
                    // Save image to photos
                    final result = await saveImageToGallery(image);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child:  Theme.of(context).brightness == Brightness.light
                        ? ColorFiltered(colorFilter: ColorFilter.mode(
                        Colors.black, BlendMode.srcIn),
                        child :  SvgPicture.asset('assets/delete 1.svg')
                    )
                        :SvgPicture.asset('assets/delete 1.svg'),
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      AppLocalizations.of(context)!.deleteMedia,
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
          title: Center(
              child: Text(
                AppLocalizations.of(context)!.createNewAlbum,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text(
                    AppLocalizations.of(context)!.enterANameForThisAlbum,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500),
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
                    hintText: AppLocalizations.of(context)!.title,
                    border: InputBorder.none, // Remove default border
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                    minimumSize: MaterialStateProperty.all(Size(100, 40)),
                    // Set button size
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).brightness == Brightness.light
                          ? Color(0xFFE8E8E8) // Color for light theme
                          : Consts.BG_COLOR,
                    ), // Set background color
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
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
                    minimumSize: MaterialStateProperty.all(Size(100, 40)),
                    // Set button size
                    backgroundColor: MaterialStateProperty.all(
                        Consts.COLOR), // Set background color
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.confirm,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
