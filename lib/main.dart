import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';
import 'services/face_analysis_service.dart';

// Favorites Service for managing user's favorite hairstyles
// The service is below
class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get _favoritesCollection {
    return _firestore.collection('users').doc(_userId).collection('favorites');
  }

  // Stream of favorite hairstyle names
  static Stream<Set<String>> favoritesStream() {
    if (_userId == null) return Stream.value({});
    return _favoritesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  // Add a hairstyle to favorites
  static Future<void> addFavorite(String hairstyleName) async {
    if (_userId == null) return;
    await _favoritesCollection.doc(hairstyleName).set({
      'name': hairstyleName,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove a hairstyle from favorites
  static Future<void> removeFavorite(String hairstyleName) async {
    if (_userId == null) return;
    await _favoritesCollection.doc(hairstyleName).delete();
  }

  // Toggle favorite status
  static Future<void> toggleFavorite(
    String hairstyleName,
    bool isFavorite,
  ) async {
    if (isFavorite) {
      await removeFavorite(hairstyleName);
    } else {
      await addFavorite(hairstyleName);
    }
  }
}

// App Colors - Apple-inspired palette
const Color kPrimaryBlue = Color(0xFF007AFF); // iOS Blue
const Color kDarkBackground = Color(0xFF000000);
const Color kLightBackground = Color(0xFFF2F2F7); // iOS Light Gray
const Color kCardBackgroundLight = Colors.white;
const Color kCardBackgroundDark = Color(0xFF1C1C1E); // iOS Dark Card
const Color kSubtleGray = Color(0xFFF2F2F7);
const Color kSecondaryLabel = Color(0xFF8E8E93); // iOS Secondary Label

// Theme notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Naya Roop',
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: kLightBackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: kPrimaryBlue,
              primary: kPrimaryBlue,
              surface: kLightBackground,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.interTextTheme().copyWith(
              headlineMedium: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
              titleLarge: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
              titleMedium: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              titleSmall: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              bodyMedium: GoogleFonts.inter(color: kSecondaryLabel),
              bodySmall: GoogleFonts.inter(color: kSecondaryLabel),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: kPrimaryBlue,
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryBlue,
                side: const BorderSide(color: kPrimaryBlue),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: kDarkBackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: kPrimaryBlue,
              primary: kPrimaryBlue,
              surface: kDarkBackground,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
                .copyWith(
                  headlineMedium: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(221, 255, 255, 255),
                  ),
                  titleLarge: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(221, 255, 255, 255),
                  ),
                  titleMedium: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(221, 255, 255, 255),
                  ),
                  titleSmall: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(221, 255, 255, 255),
                  ),
                  bodyMedium: GoogleFonts.inter(color: Colors.white70),
                  bodySmall: GoogleFonts.inter(color: Colors.white70),
                ),
            appBarTheme: AppBarTheme(
              backgroundColor: kPrimaryBlue,
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryBlue,
                side: const BorderSide(color: kPrimaryBlue),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
              ),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ============================================================================
// SPLASH SCREEN WITH LOGIN
// ============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _morphController;
  late AnimationController _buttonController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeInLogoAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  bool _showLoginButton = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Rotation animation - spins the box
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Morph animation - transforms box to logo
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeOutCubic),
    );

    // Border radius morph (square to rounded)
    _borderRadiusAnimation = Tween<double>(begin: 8.0, end: 24.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeOut),
    );

    // Size animation (small box to logo size)
    _sizeAnimation = Tween<double>(begin: 60.0, end: 120.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeOutBack),
    );

    // Fade in logo
    _fadeInLogoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _morphController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Button animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic),
    );

    // Check auth and start animation
    _checkAuthAndAnimate();
  }

  void _checkAuthAndAnimate() async {
    // Wait a moment to show full screen gigachad
    await Future.delayed(const Duration(milliseconds: 600));

    // Start rotation
    _rotationController.forward();

    // Start morph after rotation begins
    await Future.delayed(const Duration(milliseconds: 400));
    _morphController.forward();

    // Check if user is already logged in
    await Future.delayed(const Duration(milliseconds: 1400));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      // User is logged in, go to home
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              HomePage(user: user),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else if (mounted) {
      // Show login button
      setState(() => _showLoginButton = true);
      _buttonController.forward();
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _showSnack('Sign-in cancelled');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted && userCredential.user != null) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomePage(user: userCredential.user!),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (error) {
      _showSnack('Google sign-in failed');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _morphController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full screen gigachad background
          Image.asset(
            'assests/gigachad.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Dark overlay for better contrast
          Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          // Center animated box/logo
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _rotationAnimation,
                _morphAnimation,
              ]),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: _sizeAnimation.value,
                    height: _sizeAnimation.value,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        const Color(0xFF1A1A1A), // Off-black
                        Colors.transparent,
                        _morphAnimation.value * 0.3,
                      ),
                      borderRadius: BorderRadius.circular(
                        _borderRadiusAnimation.value,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.1 + (_morphAnimation.value * 0.1),
                        ),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20 + (_morphAnimation.value * 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        _borderRadiusAnimation.value,
                      ),
                      child: Opacity(
                        opacity: _fadeInLogoAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: Image.asset(
                              'assests/nayaroopkologo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // App name and login button at bottom
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // App name
                AnimatedBuilder(
                  animation: _morphAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _morphAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'Naya Roop',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find your perfect style',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Google Sign In Button
                if (_showLoginButton)
                  SlideTransition(
                    position: _buttonSlideAnimation,
                    child: FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          onPressed: _loading ? null : _signInWithGoogle,
                          child: _loading
                              ? const CupertinoActivityIndicator(
                                  color: Colors.black87,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://www.google.com/favicon.ico',
                                      width: 20,
                                      height: 20,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.g_mobiledata,
                                        size: 24,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                if (_showLoginButton) const SizedBox(height: 16),
                if (_showLoginButton)
                  FadeTransition(
                    opacity: _buttonFadeAnimation,
                    child: Text(
                      'By continuing, you agree to our Terms of Service',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        }
        return HomePage(user: user);
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;

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

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _showSnack('Sign-in cancelled');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      _showSnack('Google sign-in failed');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    final tertiaryTextColor = isDark ? Colors.white54 : Colors.black38;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // App Logo
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [textColor, textColor],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Image.asset(
                  'assests/login face scan.png',
                  width: 320,
                  height: 320,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Naya Roop',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Discover the perfect hairstyle\nfor your face shape',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  color: subtextColor,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 3),
              // Sign in button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black87,
                    foregroundColor: isDark ? Colors.black87 : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? CupertinoActivityIndicator(
                          color: isDark ? Colors.black87 : Colors.white,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'By continuing, you agree to our Terms of Service',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: tertiaryTextColor,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

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
      'avoid': [
        'Heavy Straight Fringe',
        'Bowl Cut',
      ],
      'note': 'Add height and angles to reduce roundness.',
    },
    'Square': {
      'best': [
        'Crew Cut / Ivy League',
        'Textured Crop + Mid Fade',
        'Side Part Taper',
      ],
      'avoid': [
        'Ultra Boxy Flat-Top',
      ],
      'note': 'Strong jaw works best with texture and clean structure.',
    },
    'Oblong': {
      'best': [
        'Textured Fringe',
        'Curtains / Medium Layered Cut',
        'Low Taper + Natural Top',
      ],
      'avoid': [
        'High Pompadour',
        'Very Tall Top with High Fade',
      ],
      'note': 'Reduce face length; avoid excess height.',
    },
    'Heart': {
      'best': [
        'Side-Swept Fringe',
        'Textured Crop',
        'Low Taper + Layered Top',
      ],
      'avoid': [
        'Tight Sides with Huge Top Volume',
      ],
      'note': 'Soften wide forehead; keep top balanced.',
    },
    'Oval': {
      'best': [
        'Textured Crop',
        'Side Part',
        'Curtains',
      ],
      'avoid': [
        'Extreme Height Styles',
      ],
      'note': 'Balanced face—most styles work, avoid extremes.',
    },
  };

  final Map<String, List<Map<String, String>>> _sunglassesRecommendations = {
    'Oval': [
      {'name': 'Aviators', 'icon': '🕶️', 'tip': 'Classic choice - almost any style works for you'},
      {'name': 'Wayfarers', 'icon': '😎', 'tip': 'Timeless style for balanced proportions'},
      {'name': 'Rectangular', 'icon': '▬', 'tip': 'Sharp, modern edge for your versatile face'},
    ],
    'Round': [
      {'name': 'Rectangular', 'icon': '▬', 'tip': 'Creates structure and makes face appear longer'},
      {'name': 'Square Frames', 'icon': '⬛', 'tip': 'Adds definition to soft features'},
      {'name': 'Wayfarers', 'icon': '😎', 'tip': 'Angular shape balances roundness'},
    ],
    'Square': [
      {'name': 'Round Frames', 'icon': '⭕', 'tip': 'Softens strong jawline and angular features'},
      {'name': 'Oval Frames', 'icon': '⬭', 'tip': 'Balances and softens angular features'},
      {'name': 'Aviators', 'icon': '🕶️', 'tip': 'Teardrop shape softens rather than highlights angles'},
    ],
    'Heart': [
      {'name': 'Aviators', 'icon': '🕶️', 'tip': 'Adds width to the jawline area'},
      {'name': 'Rimless', 'icon': '👓', 'tip': 'Light frames balance broad forehead'},
      {'name': 'Bottom-Heavy Frames', 'icon': '⌄', 'tip': 'Wider at bottom adds width to narrow chin'},
    ],
    'Oblong': [
      {'name': 'Oversized', 'icon': '🔳', 'tip': 'Breaks up the length of your face'},
      {'name': 'Wayfarers', 'icon': '😎', 'tip': 'Adds width to narrow face'},
      {'name': 'Decorative Temples', 'icon': '✨', 'tip': 'Draws attention sideways to break up length'},
    ],
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

  /// Analyze face shape using ML Kit + TFLite
  Future<void> _analyzeFaceShape() async {
    if (_imageFile == null) return;
    
    setState(() {
      _analyzing = true;
      _analysisError = null;
    });

    try {
      debugPrint('Starting face analysis for: ${_imageFile!.path}');
      final result = await FaceAnalysisService.instance.analyzeImage(_imageFile!);
      debugPrint('Analysis complete: ${result.faceShape}');
      
      if (mounted) {
        setState(() {
          _analysisResult = result;
          _selectedFaceShape = result.faceShape;
          _analyzing = false;
        });
        
        _showSnack(
          'Detected: ${result.faceShape} face (${(result.confidence * 100).toStringAsFixed(0)}% confidence)',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Face analysis error: $e');
      debugPrint('Stack trace: $stackTrace');
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
    final tertiaryTextColor = isDark ? Colors.white54 : Colors.black38;
    final cardBackground = isDark ? kCardBackgroundDark : kCardBackgroundLight;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.1);

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
                        // Theme toggle button
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
                        // Sign Out button
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
                          (style) => _HairstyleCard(
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

            // Recommendations Section
            if (_selectedFaceShape != null)
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
                      // Style note
                      if (_hairstyleRecommendations[_selectedFaceShape]?['note'] != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: kPrimaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: kPrimaryBlue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.lightbulb,
                                color: kPrimaryBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _hairstyleRecommendations[_selectedFaceShape]!['note'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Best styles
                      Text(
                        '✓ Best Styles',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...((_hairstyleRecommendations[_selectedFaceShape]?['best'] as List<String>?) ?? [])
                          .map(
                            (style) => _HairstyleCard(
                              title: style,
                              userId: widget.user.uid,
                              isRecommended: true,
                            ),
                          ),
                      const SizedBox(height: 16),
                      // Styles to avoid
                      Text(
                        '✗ Styles to Avoid',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...((_hairstyleRecommendations[_selectedFaceShape]?['avoid'] as List<String>?) ?? [])
                          .map(
                            (style) => _AvoidStyleCard(title: style),
                          ),
                    ],
                  ),
                ),
              ),

            // Sunglasses Recommendations Section
            if (_selectedFaceShape != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🕶️',
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Sunglasses for $_selectedFaceShape',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Frame styles that complement your face shape',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...(_sunglassesRecommendations[_selectedFaceShape] ?? [])
                          .map(
                            (sunglass) => _SunglassCard(
                              name: sunglass['name']!,
                              icon: sunglass['icon']!,
                              tip: sunglass['tip']!,
                            ),
                          ),
                    ],
                  ),
                ),
              ),

            // Divider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: tertiaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: dividerColor)),
                  ],
                ),
              ),
            ),

            // Photo Analysis Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            // Confidence bars for all shapes
                            ...(_analysisResult!.allScores.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value)))
                                .map((entry) {
                              final isTop = entry.key == _analysisResult!.faceShape;
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
                                          color: isTop ? textColor : subtextColor,
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
                                                  ? Colors.white.withValues(alpha: 0.1)
                                                  : Colors.black.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: entry.value,
                                            child: Container(
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: isTop
                                                    ? kPrimaryBlue
                                                    : kPrimaryBlue.withValues(alpha: 0.4),
                                                borderRadius: BorderRadius.circular(3),
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
                    const _StepCard(
                      number: '1',
                      title: 'Upload or Take a Photo',
                      description:
                          'Capture a clear, front-facing photo with good lighting.',
                      icon: CupertinoIcons.camera,
                    ),
                    const SizedBox(height: 12),
                    const _StepCard(
                      number: '2',
                      title: 'AI Detection',
                      description:
                          'Our model analyzes facial features to determine your shape.',
                      icon: CupertinoIcons.sparkles,
                    ),
                    const SizedBox(height: 12),
                    const _StepCard(
                      number: '3',
                      title: 'Get Recommendations',
                      description:
                          'Receive personalized hairstyle suggestions that suit you.',
                      icon: CupertinoIcons.heart,
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

class _HairstyleCard extends StatefulWidget {
  const _HairstyleCard({
    required this.title,
    required this.userId,
    this.isRecommended = false,
  });

  final String title;
  final String userId;
  final bool isRecommended;

  @override
  State<_HairstyleCard> createState() => _HairstyleCardState();
}

class _HairstyleCardState extends State<_HairstyleCard> {
  bool _isExpanded = false;

  // Map hairstyle names to asset file names
  static const Map<String, String> _hairstyleImages = {
    'Classic Pompadour': 'assests/Classic Pompadour.webp',
    'Side Part': 'assests/Side Part.jpg',
    'Side Part with Volume': 'assests/Side Part.jpg',
    'Textured Quiff': 'assests/Textured Quiff.jpg',
    'Buzz Cut': 'assests/buzz cut.webp',
    'Long Layers': 'assests/Long Layered.jpg',
    'High Fade': 'assests/high fade.webp',
    'High Fade + Textured Top': 'assests/high fade.webp',
    'Short Quiff': 'assests/Textured Quiff.jpg',
    'Pompadour': 'assests/Pompadour.jpg',
    'Faux Hawk': 'assests/Faux Hauxk.jpg',
    'Angular Fringe': 'assests/Angular Fringe.jpg',
    'Spiky Hair': 'assests/Spiky Hair .jpg',
    'Textured Crop': 'assests/Textured crop.jpg',
    'Textured Crop + Mid Fade': 'assests/Textured crop.jpg',
    'Side Swept': 'assests/Side Swept.webp',
    'Classic Taper': 'assests/CLassic taper.jpg',
    'Medium Length Waves': 'assests/Classic Medium.jpg',
    'Slick Back': 'assests/Slick Back.jpg',
    'Fringe Styles': 'assests/Angular Fringe.jpg',
    'Medium Length': 'assests/Classic Medium.jpg',
    'Textured Layers': 'assests/Long Layered.jpg',
    'Chin-Length Bob': 'assests/Classic Medium.jpg',
    'Side Fringe': 'assests/Angular Fringe.jpg',
    'Layered Cut': 'assests/Long Layered.jpg',
    'Wavy Styles': 'assests/Classic Medium.jpg',
    'Full Bangs': 'assests/Angular Fringe.jpg',
    'Volume on Sides': 'assests/Pompadour.jpg',
    'Textured Fringe': 'assests/Angular Fringe.jpg',
    'Chin-Length Styles': 'assests/Classic Medium.jpg',
    'Wispy Bangs': 'assests/Angular Fringe.jpg',
    'Soft Layers': 'assests/Long Layered.jpg',
    // New styles
    'Crew Cut / Ivy League': 'assests/CLassic taper.jpg',
    'Side Part Taper': 'assests/Side Part.jpg',
    'Curtains / Medium Layered Cut': 'assests/Classic Medium.jpg',
    'Curtains': 'assests/Classic Medium.jpg',
    'Low Taper + Natural Top': 'assests/CLassic taper.jpg',
    'Side-Swept Fringe': 'assests/Side Swept.webp',
    'Low Taper + Layered Top': 'assests/Long Layered.jpg',
  };

  String? get _imagePath => _hairstyleImages[widget.title];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black26;
    final cardBackground = isDark ? kCardBackgroundDark : kCardBackgroundLight;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kPrimaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.scissors,
                      color: kPrimaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  // Favorite button
                  StreamBuilder<Set<String>>(
                    stream: FavoritesService.favoritesStream(),
                    builder: (context, snapshot) {
                      final favorites = snapshot.data ?? {};
                      final isFavorite = favorites.contains(widget.title);
                      return GestureDetector(
                        onTap: () {
                          FavoritesService.toggleFavorite(
                            widget.title,
                            isFavorite,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isFavorite
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: isFavorite ? Colors.red : subtextColor,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      color: subtextColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _imagePath != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _imagePath!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardBackground = isDark ? kCardBackgroundDark : kCardBackgroundLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: kSecondaryLabel,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvoidStyleCard extends StatelessWidget {
  const _AvoidStyleCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.xmark_circle,
            color: Colors.red.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _SunglassCard extends StatelessWidget {
  const _SunglassCard({
    required this.name,
    required this.icon,
    required this.tip,
  });

  final String name;
  final String icon;
  final String tip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardBackground = isDark ? kCardBackgroundDark : kCardBackgroundLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tip,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: kSecondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
