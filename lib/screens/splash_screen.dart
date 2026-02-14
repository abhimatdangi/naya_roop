import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/home_page.dart';

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

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeOutCubic),
    );

    _borderRadiusAnimation = Tween<double>(
      begin: 8.0,
      end: 24.0,
    ).animate(CurvedAnimation(parent: _morphController, curve: Curves.easeOut));

    _sizeAnimation = Tween<double>(begin: 60.0, end: 120.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeOutBack),
    );

    _fadeInLogoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _morphController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Curves.easeOutCubic,
          ),
        );

    _checkAuthAndAnimate();
  }

  void _checkAuthAndAnimate() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _rotationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _morphController.forward();
    await Future.delayed(const Duration(milliseconds: 1400));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
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

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

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
          Image.asset(
            'assests/gigachad.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withValues(alpha: 0.5)),
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
                        const Color(0xFF1A1A1A),
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
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
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
