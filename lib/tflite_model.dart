import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class TfliteModel {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/yolo11n-pose_float32.tflite');
    print("Interpreter loaded successfully");
    print("Input tensor count: ${_interpreter!.getInputTensors().length}");
    print("Output tensor count: ${_interpreter!.getOutputTensors().length}");
    print("Input tensor shape: ${_interpreter!.getInputTensors()[0].shape}");
    print("Output tensor shape: ${_interpreter!.getOutputTensors()[0].shape}");
  }

  // processCameraImage method
  // Future<Float32List> processCameraImage(CameraImage image) async {
  //   // Convert the image to a format suitable for the model
  //   print("Input tensor count: ${_interpreter!.getInputTensors().length}");
  //   print("Output tensor count: ${_interpreter!.getOutputTensors().length}");
  //   print("Input tensor shape: ${_interpreter!.getInputTensors()[0].shape}");
  //   print("Output tensor shape: ${_interpreter!.getOutputTensors()[0].shape}");
  //   print("Image width: ${image.width}, height: ${image.height}");
  //   img.Image convertedImage = img.Image.fromBytes(
  //     width: image.width,
  //     height: image.height,
  //     bytes: image.planes[0].bytes.buffer,
  //     numChannels: image.planes[0].bytesPerPixel,
  //   );

  //   print("Converted image width: ${convertedImage.width}, height: ${convertedImage.height}");

  //   img.Image resizedImage = img.copyResize(convertedImage, width: 640, height: 640);

  //   print("Resized image width: ${resizedImage.width}, height: ${resizedImage.height}");

  //   // Convert the image to a byte array and return it
  //   return resizedImage.data!.buffer.asFloat32List();
  // }

  List<List<List<List<double>>>> processCameraImage(CameraImage image) {
    // Convert the image to a format suitable for the model
    print("Input tensor count: ${_interpreter!.getInputTensors().length}");
    print("Output tensor count: ${_interpreter!.getOutputTensors().length}");
    print("Input tensor shape: ${_interpreter!.getInputTensors()[0].shape}");
    print("Output tensor shape: ${_interpreter!.getOutputTensors()[0].shape}");
    print("Image width: ${image.width}, height: ${image.height}");
    img.Image convertedImage = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      numChannels: image.planes[0].bytesPerPixel,
    );

    print("Converted image width: ${convertedImage.width}, height: ${convertedImage.height}");

    img.Image resizedImage = img.copyResize(convertedImage, width: 640, height: 640);

    print("Resized image width: ${resizedImage.width}, height: ${resizedImage.height}");

    // Convert the image to a byte array
    Float32List float32list = resizedImage.data!.buffer.asFloat32List();

    // Reshape the byte array to match the model's input shape (e.g., 1x640x640x3)
    int batchSize = 1;
    int imageHeight = 640;
    int imageWidth = 640;
    int numChannels = 3;
    List<List<List<List<double>>>> input = List.generate(
      batchSize,
      (_) => List.generate(
        imageHeight,
        (i) => List.generate(
          imageWidth,
          (j) => List.generate(
            numChannels,
            (k) => float32list[i * imageHeight * imageWidth * numChannels + j * imageWidth * numChannels + k].toDouble(),
          ),
        ),
      ),
    );
  
    return input;
  }

  Future<void> runInference(List<List<List<List<double>>>> input) async {
    // Output model shape is [1, 56, 8400]
    var output = List.generate(1, (i) => List.generate(56, (j) => List.generate(8400, (k) => 0.0)));
    _interpreter!.run(input, output);
    print(output);
  }
}
