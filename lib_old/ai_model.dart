import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
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
  img.Image resizedImage = img.copyResize(convertedImage, width: 640, height: 640);

  // Convert the image to a byte array and return it
  return resizedImage.getBytes();
}

class TfliteModel {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/yolo11n-pose_float32.tflite');
  }

  Future<void> runInference(List<double> input) async {
    var output = List<double>.filled(1, 0);
    _interpreter!.run(input, output);
    print(output);
  }
}
