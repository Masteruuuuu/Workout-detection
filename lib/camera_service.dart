// import 'package:camera/camera.dart';

// class CameraService {
//   CameraController? _controller;
//   late List<CameraDescription> _cameras;
//   CameraController? get controller => _controller;

//   Future<void> initializeCamera() async {
//     // Fetch available cameras
//     _cameras = await availableCameras();

//     // Select the front camera
//     CameraDescription frontCamera = _cameras.firstWhere(
//         (camera) => camera.lensDirection == CameraLensDirection.front);

//     // Initialize the camera controller
//     _controller = CameraController(frontCamera, ResolutionPreset.medium);
    
//     // Initialize the controller
//     await _controller!.initialize();
//   }
// }

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'tflite_model.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  final TfliteModel model = TfliteModel();

  @override
  void initState() {
    super.initState();
    initCamera();
    model.loadModel();
  }

  // Initialize the camera
  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
    );
    await _controller.initialize();

    // Start the image stream to process frames
    _controller.startImageStream((image) async {
      // Convert the image to a format suitable for the model (e.g., 640x640). Every 2 seconds, the model will run inference on the image.
      if (DateTime.now().second % 2 == 0) {
        if (image.format.group == ImageFormatGroup.yuv420) {
          var input = await model.processCameraImage(image);
          print(input);
          await model.runInference(input);
        } else {
          print('Invalid image format');
        }
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pose Estimation'),
      ),
      body: _controller.value.isInitialized
          ? CameraPreview(
            _controller,
          )  // Display camera feed
          : Center(child: CircularProgressIndicator()),
    );
  }
}

