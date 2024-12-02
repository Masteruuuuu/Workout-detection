import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PoseDetector {
  final interpreter = Interpreter.fromAsset('assets/yolo11n-pose_float32.tflite');
}
