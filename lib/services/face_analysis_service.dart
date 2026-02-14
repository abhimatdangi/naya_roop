import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// Holds the detected face shape + confidence scores
class FaceAnalysisResult {
  final String faceShape;
  final double confidence;
  final Map<String, double> allScores;
  final img.Image? croppedFace;

  FaceAnalysisResult({
    required this.faceShape,
    required this.confidence,
    required this.allScores,
    this.croppedFace,
  });
}

// Detects face using ML Kit, classifies shape using TFLite
class FaceAnalysisService {
  static FaceAnalysisService? _instance;
  static FaceAnalysisService get instance => _instance ??= FaceAnalysisService._();
  FaceAnalysisService._();

  Interpreter? _interpreter;
  FaceDetector? _faceDetector;
  bool _isInitialized = false;

  static const int _inputSize = 260;
  static const double _marginMultiplier = 0.35;

  // Must match training label order
  static const List<String> _faceShapeLabels = [
    'Heart',
    'Oblong',
    'Oval',
    'Round',
    'Square',
  ];

  // Load TFLite model + ML Kit face detector
  Future<void> initialize() async {
    if (_isInitialized) return;

    _interpreter = await Interpreter.fromAsset(
      'assets/models/face_shape_b0_260_final.tflite',
    );

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: false,
        enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
      ),
    );

    _isInitialized = true;
  }

  Future<void> dispose() async {
    _interpreter?.close();
    await _faceDetector?.close();
    _interpreter = null;
    _faceDetector = null;
    _isInitialized = false;
    _instance = null;
  }

  // Main method: detect face → crop → classify shape
  Future<FaceAnalysisResult> analyzeImage(File imageFile) async {
    if (!_isInitialized) await initialize();

    // Decode image
    final bytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) throw Exception('Failed to decode image');

    // Detect face with ML Kit
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetector!.processImage(inputImage);
    if (faces.isEmpty) {
      throw Exception('No face detected. Please use a clear, front-facing photo.');
    }

    // Pick the largest face
    final face = _selectBestFace(faces);

    // Crop face with margins → resize to model input
    final croppedFace = _cropFaceWithMargins(originalImage, face.boundingBox);
    final resizedFace = img.copyResize(
      croppedFace,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Run TFLite inference
    final inputTensor = _prepareInputTensor(resizedFace);
    final outputTensor = List.filled(1 * _faceShapeLabels.length, 0.0)
        .reshape([1, _faceShapeLabels.length]);
    _interpreter!.run(inputTensor, outputTensor);

    // Get probabilities via softmax
    final scores = (outputTensor[0] as List<double>);
    final softmaxScores = _softmax(scores);

    // Find top prediction
    int maxIndex = 0;
    double maxScore = softmaxScores[0];
    for (int i = 1; i < softmaxScores.length; i++) {
      if (softmaxScores[i] > maxScore) {
        maxScore = softmaxScores[i];
        maxIndex = i;
      }
    }

    // Build scores map
    final allScores = <String, double>{};
    for (int i = 0; i < _faceShapeLabels.length; i++) {
      allScores[_faceShapeLabels[i]] = softmaxScores[i];
    }

    return FaceAnalysisResult(
      faceShape: _faceShapeLabels[maxIndex],
      confidence: maxScore,
      allScores: allScores,
      croppedFace: croppedFace,
    );
  }

  // Pick largest face by bounding box area
  Face _selectBestFace(List<Face> faces) {
    if (faces.length == 1) return faces.first;
    
    return faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA > areaB ? a : b;
    });
  }

  // Crop face region with extra margin, then make square
  img.Image _cropFaceWithMargins(img.Image image, ui.Rect boundingBox) {
    final marginX = (boundingBox.width * _marginMultiplier).round();
    final marginY = (boundingBox.height * _marginMultiplier).round();

    final left = (boundingBox.left - marginX).clamp(0, image.width - 1).round();
    final top = (boundingBox.top - marginY).clamp(0, image.height - 1).round();
    final right = (boundingBox.right + marginX).clamp(0, image.width).round();
    final bottom = (boundingBox.bottom + marginY).clamp(0, image.height).round();

    final cropWidth = right - left;
    final cropHeight = bottom - top;
    if (cropWidth <= 0 || cropHeight <= 0) {
      throw Exception('Invalid crop dimensions');
    }

    final cropped = img.copyCrop(
      image,
      x: left,
      y: top,
      width: cropWidth,
      height: cropHeight,
    );
    return _makeSquare(cropped);
  }

  // Center-crop to square
  img.Image _makeSquare(img.Image image) {
    if (image.width == image.height) return image;
    final size = image.width < image.height ? image.width : image.height;
    final offsetX = (image.width - size) ~/ 2;
    final offsetY = (image.height - size) ~/ 2;
    return img.copyCrop(image, x: offsetX, y: offsetY, width: size, height: size);
  }

  // Convert image to float32 tensor [1, 260, 260, 3], values 0-255
  List<List<List<List<double>>>> _prepareInputTensor(img.Image image) {
    return List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final pixel = image.getPixel(x, y);
          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        }),
      ),
    );
  }

  // Softmax: logits → probabilities
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final expValues = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sumExp = expValues.reduce((a, b) => a + b);
    return expValues.map((e) => e / sumExp).toList();
  }
}
