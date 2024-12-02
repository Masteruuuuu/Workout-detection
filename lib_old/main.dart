import 'package:flutter/material.dart';
import 'camera_view.dart';
import 'pose_estimation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadModel();  // Load the TFLite model
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose Estimation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraView(),
    );
  }
}
