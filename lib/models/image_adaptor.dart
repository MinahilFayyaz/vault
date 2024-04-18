import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;

class ImageAdapter extends TypeAdapter<img.Image?> {
  @override
  int get typeId => 0;

  @override
  img.Image? read(BinaryReader reader) {
    final List<int> bytes = reader.readByteList();
    if (bytes.isEmpty) return null;
    return img.decodeJpg(Uint8List.fromList(bytes));
  }

  @override
  void write(BinaryWriter writer, img.Image? image) {
    if (image != null) {
      final encodedImage = img.encodeJpg(image, quality: 100);
      writer.writeByteList(encodedImage);
    } else {
      writer.writeByteList([]);
    }
  }
}
