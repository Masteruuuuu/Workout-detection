import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

Future<Uint8List> processCameraImage(CameraImage image) async {
  // Convert the image to a format suitable for the model
  img.Image convertedImage = img.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: image.planes[0].bytes.buffer,
    );
  
  // Resize the image to the model's input size (e.g., 224x224)
  img.Image resizedImage = img.copyResize(convertedImage, width: 224, height: 224);

  // Convert the image to a byte array and return it
  return resizedImage.getBytes();
}
