import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'pose_estimation.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    initCamera();
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
      await processFrame(image);
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
          ? CameraPreview(_controller)  // Display camera feed
          : Center(child: CircularProgressIndicator()),
    );
  }
}
