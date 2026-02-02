import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Result of face analysis containing detected face shape and confidence scores
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

  @override
  String toString() {
    return 'FaceAnalysisResult(faceShape: $faceShape, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Service for detecting faces and running face shape classification
class FaceAnalysisService {
  static FaceAnalysisService? _instance;
  static FaceAnalysisService get instance => _instance ??= FaceAnalysisService._();

  FaceAnalysisService._();

  Interpreter? _interpreter;
  FaceDetector? _faceDetector;
  bool _isInitialized = false;

  // Model input size
  static const int _inputSize = 260;
  
  // Face shape labels (must match training order)
  static const List<String> _faceShapeLabels = [
    'Heart',
    'Oblong',
    'Oval',
    'Round',
    'Square',
  ];

  // Margin multiplier for face crop (adds extra space around detected face)
  static const double _marginMultiplier = 0.35;

  /// Initialize the service (loads model and face detector)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('Initializing FaceAnalysisService...');
      
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset(
        'assets/models/face_shape_b0_260_final.tflite',
      );
      debugPrint('TFLite model loaded successfully');
      
      // Initialize ML Kit Face Detector
      final options = FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: false,
        enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
      );
      _faceDetector = FaceDetector(options: options);
      debugPrint('Face detector initialized');

      _isInitialized = true;
      debugPrint('FaceAnalysisService initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing FaceAnalysisService: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _interpreter?.close();
    await _faceDetector?.close();
    _interpreter = null;
    _faceDetector = null;
    _isInitialized = false;
    _instance = null;
  }

  /// Analyze face shape from an image file
  /// Returns FaceAnalysisResult with detected shape and confidence
  Future<FaceAnalysisResult> analyzeImage(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    debugPrint('Step 1: Reading image file...');
    // Step 1: Read and decode the image
    final bytes = await imageFile.readAsBytes();
    debugPrint('Image bytes: ${bytes.length}');
    
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }
    debugPrint('Image decoded: ${originalImage.width}x${originalImage.height}');

    // Step 2: Detect face using ML Kit
    debugPrint('Step 2: Detecting face with ML Kit...');
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetector!.processImage(inputImage);
    debugPrint('Faces detected: ${faces.length}');

    if (faces.isEmpty) {
      throw Exception('No face detected in the image. Please use a clear, front-facing photo.');
    }

    // Use the first (or largest) detected face
    final face = _selectBestFace(faces);
    final boundingBox = face.boundingBox;
    debugPrint('Face bounding box: $boundingBox');

    // Step 3: Crop and align the face with margins
    debugPrint('Step 3: Cropping face with margins...');
    final croppedFace = _cropFaceWithMargins(originalImage, boundingBox);
    debugPrint('Cropped face: ${croppedFace.width}x${croppedFace.height}');

    // Step 4: Resize to model input size (260x260)
    debugPrint('Step 4: Resizing to ${_inputSize}x$_inputSize...');
    final resizedFace = img.copyResize(
      croppedFace,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Step 5: Prepare input tensor (float32 0..255, NOT normalized)
    debugPrint('Step 5: Preparing input tensor...');
    final inputTensor = _prepareInputTensor(resizedFace);

    // Step 6: Run inference
    debugPrint('Step 6: Running TFLite inference...');
    final outputTensor = List.filled(1 * _faceShapeLabels.length, 0.0)
        .reshape([1, _faceShapeLabels.length]);
    
    _interpreter!.run(inputTensor, outputTensor);
    debugPrint('Raw output: ${outputTensor[0]}');

    // Step 7: Process results
    debugPrint('Step 7: Processing results...');
    final scores = (outputTensor[0] as List<double>);
    final softmaxScores = _softmax(scores);
    debugPrint('Softmax scores: $softmaxScores');
    
    // Find the highest scoring face shape
    int maxIndex = 0;
    double maxScore = softmaxScores[0];
    for (int i = 1; i < softmaxScores.length; i++) {
      if (softmaxScores[i] > maxScore) {
        maxScore = softmaxScores[i];
        maxIndex = i;
      }
    }

    // Create scores map
    final allScores = <String, double>{};
    for (int i = 0; i < _faceShapeLabels.length; i++) {
      allScores[_faceShapeLabels[i]] = softmaxScores[i];
    }

    debugPrint('Result: ${_faceShapeLabels[maxIndex]} with ${(maxScore * 100).toStringAsFixed(1)}% confidence');

    return FaceAnalysisResult(
      faceShape: _faceShapeLabels[maxIndex],
      confidence: maxScore,
      allScores: allScores,
      croppedFace: croppedFace,
    );
  }

  /// Select the best face from detected faces (largest by area)
  Face _selectBestFace(List<Face> faces) {
    if (faces.length == 1) return faces.first;
    
    return faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA > areaB ? a : b;
    });
  }

  /// Crop face from image with margins around the bounding box
  img.Image _cropFaceWithMargins(img.Image image, ui.Rect boundingBox) {
    // Calculate margins
    final marginX = (boundingBox.width * _marginMultiplier).round();
    final marginY = (boundingBox.height * _marginMultiplier).round();

    // Calculate crop coordinates with margins, clamped to image bounds
    final left = (boundingBox.left - marginX).clamp(0, image.width - 1).round();
    final top = (boundingBox.top - marginY).clamp(0, image.height - 1).round();
    final right = (boundingBox.right + marginX).clamp(0, image.width).round();
    final bottom = (boundingBox.bottom + marginY).clamp(0, image.height).round();

    final cropWidth = right - left;
    final cropHeight = bottom - top;

    // Ensure we have valid dimensions
    if (cropWidth <= 0 || cropHeight <= 0) {
      throw Exception('Invalid crop dimensions');
    }

    // Crop the image
    final cropped = img.copyCrop(
      image,
      x: left,
      y: top,
      width: cropWidth,
      height: cropHeight,
    );

    // Make it square by padding or cropping
    return _makeSquare(cropped);
  }

  /// Make image square by center-cropping the longer dimension
  img.Image _makeSquare(img.Image image) {
    if (image.width == image.height) return image;

    final size = image.width < image.height ? image.width : image.height;
    final offsetX = (image.width - size) ~/ 2;
    final offsetY = (image.height - size) ~/ 2;

    return img.copyCrop(
      image,
      x: offsetX,
      y: offsetY,
      width: size,
      height: size,
    );
  }

  /// Prepare input tensor for TFLite model
  /// Input format: float32 [1, 260, 260, 3] with values 0..255 (NOT normalized)
  List<List<List<List<double>>>> _prepareInputTensor(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            // Return RGB values as float32 in range 0..255 (NOT divided by 255)
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );
    return input;
  }

  /// Apply softmax to convert logits to probabilities
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final expValues = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sumExp = expValues.reduce((a, b) => a + b);
    return expValues.map((e) => e / sumExp).toList();
  }
}
