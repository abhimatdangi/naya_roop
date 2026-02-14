import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../services/face_analysis_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hairstyle_card.dart';
import '../widgets/step_card.dart';
import '../screens/splash_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});

  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _picking = false;
  bool _analyzing = false;
  String? _selectedFaceShape;
  bool _shapeFromAnalysis = false;
  FaceAnalysisResult? _analysisResult;
  String? _analysisError;

  final List<String> _faceShapes = [
    'Oval',
    'Round',
    'Square',
    'Heart',
    'Oblong',
  ];

  final Map<String, Map<String, dynamic>> _hairstyleRecommendations = {
    'Round': {
      'best': [
        'High Fade + Textured Top',
        'Short Quiff',
        'Side Part with Volume',
      ],
    },
    'Square': {
      'best': [
        'Crew Cut / Ivy League',
        'Textured Crop + Mid Fade',
        'Side Part Taper',
      ],
    },
    'Oblong': {
      'best': [
        'Textured Fringe',
        'Curtains / Medium Layered Cut',
        'Low Taper + Natural Top',
      ],
    },
    'Heart': {
      'best': ['Side-Swept Fringe', 'Textured Crop', 'Low Taper + Layered Top'],
    },
    'Oval': {
      'best': ['Textured Crop', 'Side Part', 'Curtains'],
    },
  };

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) {
        _showSnack('No image selected');
        return;
      }
      setState(() {
        _imageFile = File(picked.path);
        _analysisResult = null;
        _analysisError = null;
      });
      _showSnack('Image ready for analysis');
    } catch (error) {
      _showSnack('Could not pick image');
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  Future<void> _analyzeFaceShape() async {
    if (_imageFile == null) return;

    setState(() {
      _analyzing = true;
      _analysisError = null;
    });

    try {
      final result = await FaceAnalysisService.instance.analyzeImage(
        _imageFile!,
      );

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _selectedFaceShape = result.faceShape;
          _shapeFromAnalysis = true;
          _analyzing = false;
        });

        _showSnack(
          'Detected: ${result.faceShape} face (${(result.confidence * 100).toStringAsFixed(0)}% confidence)',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analyzing = false;
          _analysisError = e.toString();
        });
        _showSnack(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  void _showSignOutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showImagePickerSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          'Select Photo',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        message: Text(
          'Choose a clear, front-facing photo for best results',
          style: GoogleFonts.inter(),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: Text(
              'Take Photo',
              style: GoogleFonts.inter(color: kPrimaryBlue),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: Text(
              'Choose from Library',
              style: GoogleFonts.inter(color: kPrimaryBlue),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: Text('Cancel', style: GoogleFonts.inter()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.user.displayName?.split(' ').first ?? 'there';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    final cardBackground = isDark ? kCardBackgroundDark : kCardBackgroundLight;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $firstName',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find your perfect hairstyle',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            themeNotifier.value = isDark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isDark
                                  ? CupertinoIcons.sun_max_fill
                                  : CupertinoIcons.moon_fill,
                              color: isDark ? Colors.amber : Colors.indigo,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showSignOutDialog,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              CupertinoIcons.square_arrow_right,
                              color: isDark ? Colors.white70 : Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Face Shape Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Face Shape',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kSecondaryLabel,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _faceShapes.map((shape) {
                        final isSelected = _selectedFaceShape == shape;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedFaceShape = isSelected ? null : shape;
                            _shapeFromAnalysis = false;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kPrimaryBlue
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.04)),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                      width: 1,
                                    ),
                            ),
                            child: Text(
                              shape,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected ? Colors.white : textColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Recommendations Section (only when manually selected via chips)
            if (_selectedFaceShape != null && !_shapeFromAnalysis)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended for $_selectedFaceShape',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '✓ Best Styles',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...((_hairstyleRecommendations[_selectedFaceShape]?['best']
                                  as List<String>?) ??
                              [])
                          .map(
                            (style) => HairstyleCard(
                              title: style,
                              userId: widget.user.uid,
                              isRecommended: true,
                            ),
                          ),
                    ],
                  ),
                ),
              ),

            // My Favorites Section
            SliverToBoxAdapter(
              child: StreamBuilder<Set<String>>(
                stream: FavoritesService.favoritesStream(),
                builder: (context, snapshot) {
                  final favorites = snapshot.data ?? {};
                  if (favorites.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Favorites',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${favorites.length}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...favorites.map(
                          (style) => HairstyleCard(
                            title: style,
                            userId: widget.user.uid,

                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Photo Analysis Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyze Your Face',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Not sure about your face shape? Let us detect it for you.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _picking ? null : _showImagePickerSheet,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                        child: _imageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.camera,
                                    size: 32,
                                    color: kSecondaryLabel,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Add Photo',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to take or choose a photo',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: kSecondaryLabel,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _imageFile = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.xmark,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Analysis Results
                    if (_analysisResult != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kPrimaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: kPrimaryBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kPrimaryBlue.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    color: kPrimaryBlue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Face Shape Detected',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: kSecondaryLabel,
                                        ),
                                      ),
                                      Text(
                                        _analysisResult!.faceShape,
                                        style: GoogleFonts.inter(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimaryBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${(_analysisResult!.confidence * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...(_analysisResult!.allScores.entries.toList()
                                  ..sort((a, b) => b.value.compareTo(a.value)))
                                .map((entry) {
                                  final isTop =
                                      entry.key == _analysisResult!.faceShape;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                            entry.key,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: isTop
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: isTop
                                                  ? textColor
                                                  : subtextColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.1,
                                                        )
                                                      : Colors.black.withValues(
                                                          alpha: 0.1,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                              FractionallySizedBox(
                                                widthFactor: entry.value,
                                                child: Container(
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: isTop
                                                        ? kPrimaryBlue
                                                        : kPrimaryBlue
                                                              .withValues(
                                                                alpha: 0.4,
                                                              ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          3,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 40,
                                          child: Text(
                                            '${(entry.value * 100).toStringAsFixed(0)}%',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: subtextColor,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Error message
                    if (_analysisError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _analysisError!.replaceAll('Exception: ', ''),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: kPrimaryBlue,
                        disabledColor: kPrimaryBlue.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: (_imageFile == null || _analyzing)
                            ? null
                            : _analyzeFaceShape,
                        child: _analyzing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CupertinoActivityIndicator(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Analyzing...',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _analysisResult != null
                                    ? 'Analyze Again'
                                    : 'Analyze Face Shape',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recommendations after analysis (when detected via photo)
            if (_selectedFaceShape != null && _shapeFromAnalysis)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended for $_selectedFaceShape',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '✓ Best Styles',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...((_hairstyleRecommendations[_selectedFaceShape]?['best']
                                  as List<String>?) ??
                              [])
                          .map(
                            (style) => HairstyleCard(
                              title: style,
                              userId: widget.user.uid,
                              isRecommended: true,
                            ),
                          ),
                    ],
                  ),
                ),
              ),

            // How it Works
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How It Works',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const StepCard(
                      number: '1',
                      title: 'Upload or Take a Photo',
                      description:
                          'Capture a clear, front-facing photo with good lighting.',
                      iconAsset: 'assests/camera.png',
                    ),
                    const SizedBox(height: 12),
                    const StepCard(
                      number: '2',
                      title: 'AI Detection',
                      description:
                          'Our model analyzes facial features to determine your shape.',
                      iconAsset: 'assests/idea.png',
                    ),
                    const SizedBox(height: 12),
                    const StepCard(
                      number: '3',
                      title: 'Get Recommendations',
                      description:
                          'Receive personalized hairstyle suggestions that suit you.',
                      iconAsset: 'assests/scissor.png',
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
