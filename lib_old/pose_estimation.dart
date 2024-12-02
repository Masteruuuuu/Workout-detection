import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'dart:math';

late Interpreter _interpreter;

// Load the model from assets
Future<void> loadModel() async {
  _interpreter = await Interpreter.fromAsset('assets/yolo11n-pose_float32.tflite');
}

// Process each frame from the camera feed
// Future<void> processFrame(CameraImage image) async {
//   // Convert CameraImage to a format that TFLite can process (640x640 RGB)
//   var input = await _convertCameraImageToInput(image);

//   // Prepare output tensor (adjust the output size based on your model)
//   var output = List.generate(1, (i) => List.generate(1, (j) => List.generate(1, (k) => 0.0))); // Placeholder shape

//   // Run the model
//   _interpreter.run(input, output);

//   // Process the output (pose landmarks, etc.)
//   print(output);
// }

DateTime? _lastProcessedTime;

Future<void> processFrame(CameraImage image) async {
  DateTime now = DateTime.now();

  // Print the format of the camera image
  print("Camera Image format: ${image.format.group}");

  // Optionally, you can print the size of the planes to understand the image structure
  print("Y plane size: ${image.planes[0].bytes.length}");
  print("U plane size: ${image.planes[1].bytes.length}");
  print("V plane size: ${image.planes[2].bytes.length}");

  // Process frame only if 5 seconds have passed
  if (_lastProcessedTime == null || now.difference(_lastProcessedTime!).inSeconds >= 5) {
    _lastProcessedTime = now;

    // Convert CameraImage to a format that TFLite can process (640x640 RGB)
    var input = await _convertCameraImageToInput(image);

    // Prepare output tensor (adjust the output size based on your model)
    var output = List.generate(1, (i) => List.generate(1, (j) => List.generate(1, (k) => 0.0))); // Placeholder shape

    // Run the model
    _interpreter.run(input, output);

    // Process the output (pose landmarks, etc.)
    print(output);
  } else {
    // Skip processing this frame
    print("Skipping frame");
  }
}

// Convert CameraImage to input format for TFLite
Future<List<List<List<List<double>>>>> _convertCameraImageToInput(CameraImage image) async {
  int width = 640;
  int height = 640;

  // Resize the image to 640x640
  var rgbaImage = await _yuvToRgb(image, width, height);

  // Normalize and prepare the input
  List<List<List<List<double>>>> input = List.generate(
    1,
    (i) => List.generate(
      height,
      (j) => List.generate(
        width,
        (k) => List.generate(3, (l) {
          // Normalize RGB to [0.0, 1.0]
          return rgbaImage[j][k][l] / 255.0;
        }),
      ),
    ),
  );

  return input;
}

// Convert YUV image to RGB
Future<List<List<List<int>>>> _yuvToRgb(CameraImage image, int width, int height) async {
  // Create an empty image buffer to hold RGB values
  List<List<List<int>>> rgbaImage = List.generate(height, (i) => List.generate(width, (j) => List.filled(3, 0)));

  // Get Y, U, and V planes
  Uint8List yPlane = image.planes[0].bytes; // Y plane (brightness)
  Uint8List uPlane = image.planes[1].bytes; // U plane (chroma)
  Uint8List vPlane = image.planes[2].bytes; // V plane (chroma)

  int uvRowStride = image.planes[1].bytesPerRow;  // Row stride for U and V planes
  int uvPixelStride = image.planes[1].bytesPerPixel!; // Pixel stride for U and V planes

  int uvIndex = 0;

  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
      // Y component (luminance)
      int y = yPlane[i + j * width];

      // U and V components (chrominance), U and V planes have half resolution
      int u = uPlane[uvIndex + (j ~/ 2) * uvRowStride + (i ~/ 2) * uvPixelStride];
      int v = vPlane[uvIndex + (j ~/ 2) * uvRowStride + (i ~/ 2) * uvPixelStride];

      // YUV to RGB conversion
      int r = (y + 1.402 * (v - 128)).clamp(0, 255).toInt();
      int g = (y - 0.344136 * (u - 128) - 0.714136 * (v - 128)).clamp(0, 255).toInt();
      int b = (y + 1.772 * (u - 128)).clamp(0, 255).toInt();

      // Store the RGB values in the output buffer
      rgbaImage[j][i] = [r, g, b];

      // Increment UV index for every two pixels horizontally (UV plane is subsampled)
      if (i % 2 == 0 && j % 2 == 0) uvIndex++;
    }
  }
  return rgbaImage;
}

