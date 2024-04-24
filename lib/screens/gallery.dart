import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
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
                      return _buildImageWidget(file, asset.type);
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
      if (asset.type == AssetType.image) {
        final imageName = file.path
            .split('/')
            .last;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imageFile: file,
              imageName: imageName,
              folderName: '',),
          ),
        );
      } else if (asset.type == AssetType.video) {
        print("video : $file");
        final videoName = file!.path.split('/').last;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imageFile: file,
              imageName: videoName,
              folderName: '',),
          ),
        );
      }
    }

  }

  Widget _buildImageWidget(File file, AssetType type) {
    final String filePath = file.path.toLowerCase();
    if (filePath.endsWith('.mp4') || filePath.endsWith('.mov')) {
      print('file path : $type');// If it's a video file, return a video player widget
      return _buildVideoWidget(file);
    } else {
      print('file path : $type');
      // If it's an image file, load it as an image
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
  }

  Widget _buildVideoWidget(File file) {
    return FutureBuilder(
      future: _generateThumbnail(file),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          final Uint8List thumbnailBytes = snapshot.data as Uint8List;
          return Image.memory(
            thumbnailBytes,
            width: 100, // Set a fixed width for the thumbnail
            height: 100,
            fit: BoxFit.cover,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<Uint8List?> _generateThumbnail(File file) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.PNG, // Choose the desired image format
      quality: 50, // Adjust the quality of the thumbnail (0 - 100)
    );
    return thumbnail;
  }


  Future<Uint8List> _getVideoBytes(String filePath) async {
    File file = File(filePath);
    return await file.readAsBytes();
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

        final String mediaPath = selectedImagePaths[i];
        print('Media path at index $i: $mediaPath');

        // Determine the type of media based on file extension
        String extension = mediaPath.split('.').last.toLowerCase();
        if (extension == 'mp4' || extension == 'mov') {
          // It's a video file
          print('Saving video at index $i...');
          try {
            Uint8List videoBytes = await _getVideoBytes(mediaPath);
            await hiveService.storeVideo(mediaPath, widget.folderName!);
            print('Video at index $i saved successfully');
          } catch (error) {
            print('Failed to save video at index $i: $error');
            allImagesSaved = false;
          }
        }

        else{
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
    List<AssetType> tempImageTypes = [];

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
            print('file ${file}');
            if (file.path.toLowerCase().endsWith('.mp4') || file.path.toLowerCase().endsWith('.mov')) {
              print('file ends with mp4 ${file.path}');
              // If it's a video, add its path directly
              tempImagePaths.add(file.path);
            } else {
              print('file ends with jpg ${file.path}');
              // If it's an image, add its path after converting to bytes
              Uint8List bytes = await file.readAsBytes();
              tempImagePaths.add(file.path);
            }
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

  Future<void> storeImage(dynamic media, String folderName) async {
    print('Storing media in the database...');
    var box = await Hive.openBox(folderName);

    var key = DateTime.now().millisecondsSinceEpoch.toString();

    print('media : $media');
    if (media is Uint8List) {
      print('Uint8list media');
      // If media is image bytes, store directly
      await box.put(key, media);
      print('Image stored in database with key $key');
    } else if (media is String) {
      print('string media');
      // If media is video file path, read file and store bytes
      if (media.toLowerCase().endsWith('.mp4') || media.toLowerCase().endsWith('.mov')) {
        print('mp4 media');
        try {
          File file = File(media);
          Uint8List videoBytes = await file.readAsBytes();
          await box.put(key, videoBytes);
          print('Video stored in database with key $key');
        } catch (error) {
          print('Error storing video in database: $error');
        }
      } else {
        print('Unsupported media type');
      }
    } else {
      print('Unsupported media type');
    }
  }
  Future<void> storeVideo(String filePath, String folderName) async {
    print('Storing video in the database...');
    var box = await Hive.openBox(folderName);

    var key = DateTime.now().millisecondsSinceEpoch.toString();
     try{

          await box.put(key, filePath);
          print('Video stored in database with key $key');
        } catch (error) {
          print('Error storing video in database: $error');
        }
  }
}