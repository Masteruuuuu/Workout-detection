import 'package:flutter/material.dart';
import 'camera_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
