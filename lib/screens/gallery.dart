import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:photo_manager/photo_manager.dart';
import '../consts/consts.dart';
import 'gallerydatabaseretrieve.dart';
import 'imagepreview.dart';

class GalleryScreen extends StatefulWidget {
  final String? folderName;

  const GalleryScreen({Key? key, required this.folderName}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Widget> _images = [];
  List<bool> _isSelected = [];
  int selectedCount = 0;
  int currentPage = 0;
  HiveService hiveService = HiveService();
  List<AssetPathEntity> albums = [];
  List<String> selectedImagePaths = [];


  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery() async {
    final PermissionState permissionState = await PhotoManager.requestPermissionExtend();
    if (permissionState.isAuth) {
      _fetchImages();
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('Please grant permission to access photos.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchImages() async {
    albums = await PhotoManager.getAssetPathList(onlyAll: true);
    print('albums $albums');
    if (albums.isNotEmpty) {
      List<AssetEntity> media = await albums[0].getAssetListPaged(size: 60, page: currentPage);
      print('album[0]: ${albums[0]}');
      List<Widget> tempImages = [];
      List<bool> tempSelected = [];

      for (var asset in media) {
        if (asset.type == AssetType.image || asset.type == AssetType.video) {
          tempImages.add(
            GestureDetector(
              onTap: () => _onImageTap(asset),
              child: FutureBuilder(
                future: asset.file,
                builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final file = snapshot.data;
                    if (file != null) {
                      return _buildImageWidget(file);
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          );
          tempSelected.add(false);
        }
      }

      setState(() {
        _images.addAll(tempImages);
        _isSelected.addAll(tempSelected);
        currentPage++;
      });
    } else {
      _showAlbumNotFoundDialog();
    }
  }

  void _showAlbumNotFoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Album Not Found'),
        content: const Text('The album was not found in your photo library.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onImageTap(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      final imageName = file.path.split('/').last;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imageFile: file,
              imageName: imageName,
          folderName: '',),
        ),
      );
    }
  }

  Widget _buildImageWidget(File file) {
    return FutureBuilder(
      future: file.readAsBytes(),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> bytesSnapshot) {
        if (bytesSnapshot.connectionState == ConnectionState.done) {
          final bytes = bytesSnapshot.data;
          if (bytes != null) {
            return Container(
                width: 100, // Set a fixed width for the image
                height: 100,
                child: Image.memory(bytes, fit: BoxFit.cover)
            );
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> saveSelectedImagesToDatabase() async {
    int selectedImageCount = _isSelected.where((isSelected) => isSelected).length;
    print('Number of selected images: $selectedImageCount');

    print('Saving selected images to the database...');
    bool allImagesSaved = true;

    if (selectedImagePaths.isEmpty) {
      print('No selected image paths');
      return;
    }


    for (int i = 0; i < _images.length; i++) {
      if (_isSelected[i]) {
        Uint8List imageBytes = await _getImageBytes(selectedImagePaths[i]);

        print('Image bytes at index $i: ${imageBytes.length}');
        if (imageBytes.isNotEmpty) {
          try {
            await hiveService.storeImage(imageBytes, widget.folderName!);
            print('Image $i saved successfully');
          } catch (error) {
            print('Failed to save image $i: $error');
            allImagesSaved = false;
          }
        } else {
          print('Image bytes at index $i are empty');
          allImagesSaved = false;
        }
      }
    }

    if (allImagesSaved) {
      _showSnackBar('All selected images have been saved to the database.');
      //_openSavedImagesScreen();

    } else {
      _showSnackBar('Some images have not been saved to the database.');
    }
  }


  Future<Uint8List> _getImageBytes(String filePath) async {
    try {
      // Create a File object from the given file path
      File file = File(filePath);

      // Read the file as bytes
      Uint8List fileData = await file.readAsBytes();

      if (fileData.isNotEmpty) {
        // If the file data is not empty, return the bytes
        return fileData;
      } else {
        print('File data is empty for path $filePath');
        return Uint8List(0);
      }
    } catch (error) {
      print('Error reading image bytes for path $filePath: $error');
      return Uint8List(0);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Color(0xFFFFFFFF) // Color for light theme
            : Consts.FG_COLOR,
        title: Text(widget.folderName!),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1 / 1,
          mainAxisSpacing: 3.0, // Adjust spacing between rows as desired
          crossAxisSpacing: 3.0,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _isSelected[index] = !_isSelected[index];
                selectedCount += _isSelected[index] ? 1 : -1;
              });
            },
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0,
                  vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _images[index],
                  ),
                ),
                if (_isSelected[index])
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
              ],
            ),
          );
        }
        ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            _selectAllImages();
          } else if (index == 1) {
            _showConfirmationDialog();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.select_all),
            label: 'Select All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Lock',
          ),
        ],
      ),
    );
  }

  void _selectAllImages() async {
    setState(() {
      // Determine whether to select all images or deselect all images
      if (selectedCount == _images.length) {
        // Deselect all images
        _isSelected = List.generate(_images.length, (_) => false);
        selectedCount = 0;
        selectedImagePaths.clear();
      } else {
        // Select all images
        _isSelected = List.generate(_images.length, (_) => true);
        selectedCount = _images.length;
      }
    });

    // Create a temporary list to hold the paths
    List<String> tempImagePaths = [];

    // Iterate over each image and collect paths
    for (int i = 0; i < _images.length; i++) {
      // Extract the widget from the list
      final widget = _images[i];

      // Check if the widget is a GestureDetector
      if (widget is GestureDetector) {
        // Extract the child widget from GestureDetector
        final child = widget.child;

        // Check if the child is a FutureBuilder
        if (child is FutureBuilder) {
          // Retrieve the future from the FutureBuilder
          final future = child.future;

          // Await the future to get the file
          final file = await future;

          // Check if the file is not null and add its path to the list
          if (file != null) {
            tempImagePaths.add(file.path);
          }
        }
      }
    }

    // Update state with the collected paths
    setState(() {
      selectedImagePaths = tempImagePaths;
      print('selectedImagePaths after selection: $selectedImagePaths');
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white // Color for light theme
              : Consts.BG_COLOR, //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 70.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.light
                                      ? Color(0xFFF5F5F5) // Color for light theme
                                      : Consts.FG_COLOR,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Image widget inside the Stack
                              Positioned(
                                child: ClipOval(
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context).brightness == Brightness.light
                                            ? Colors.black // Color for light theme
                                            : Colors.white,
                                        BlendMode.srcIn),
                                    child: SvgPicture.asset(
                                      'assets/Group.svg', // Replace with the path to your image
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Move In',
                              style: const TextStyle(fontSize: 18,
                              fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Are you sure you want to move\n$selectedCount item(s)in the GalleryVault?',
                      style: TextStyle(fontSize: 16,
                      color:  Theme.of(context).brightness == Brightness.light
                          ? Color(0x7F222222)
                          : Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
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
                      minimumSize: MaterialStateProperty.all(Size(120, 40)), // Set button size
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).brightness == Brightness.light
                            ? Color(0xFFF5F5F5) // Color for light theme
                            : Consts.FG_COLOR,
                      ), // Set background color
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.light
                          ? Color(0x7F222222)
                          : Colors.white.withOpacity(0.5)
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      saveSelectedImagesToDatabase();
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(120, 40)),
                      backgroundColor: MaterialStateProperty.all(Consts.COLOR),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class HiveService {

  Future<void> storeImage(Uint8List imageBytes, String folderName) async {
    print('Storing image in the database...');
    var box = await Hive.openBox(folderName);

    var key = DateTime.now().millisecondsSinceEpoch.toString();

    bool isDuplicate = box.values.any((value) => value == imageBytes);
    if (isDuplicate) {
      print('Duplicate image found, skipping...');
      return;
    }

    await box.put(key, imageBytes);
    print('Image stored in database with key {key}');
  }
}

