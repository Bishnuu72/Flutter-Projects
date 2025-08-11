import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // <-- Add this import
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/firebase_auth/fcm_services.dart';
import 'package:manshi/services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isChecked = false;
  bool isPasswordVisible = false;
  bool isEmailLoading = false;
  bool isGoogleLoading = false;
  bool animate = false;

  final _firestore = FirebaseFirestore.instance;
  final FCMServices _fcmServices = FCMServices();

  @override
  void initState() {
    super.initState();

    // Set status bar icons/text to white (light)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent or your preferred color
      statusBarIconBrightness: Brightness.light, // Android: light icons
      statusBarBrightness: Brightness.dark, // iOS: light icons
    ));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => animate = true);
    });
  }

  // Optional: Reset status bar style when this screen disposes
  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showDialog(String title, String desc, DialogType type, {VoidCallback? onOk}) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.rightSlide,
      title: title,
      desc: desc,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  Future<void> _updateFCMToken(String userId) async {
    try {
      final fcmToken = await _fcmServices.getFCMToken();
      if (fcmToken != null) {
        await FirestoreService.updateUserFCMToken(userId, fcmToken);
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> _navigateAfterLogin(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    if (userData == null) {
      _showDialog("Error", "User data not found", DialogType.error);
      return;
    }

    final role = userData['role'] ?? 'user';
    final preferences = userData['preferences'] ?? [];

    if (role == 'admin') {
      final categoriesSnapshot = await _firestore.collection('categories').get();
      if (categoriesSnapshot.docs.isEmpty) {
        Navigator.pushReplacementNamed(context, RoutesName.adminInitScreen);
      } else {
        Navigator.pushReplacementNamed(context, RoutesName.adminDashboardScreen);
      }
    } else {
      if (preferences.isEmpty) {
        Navigator.pushReplacementNamed(context, RoutesName.preferenceSelection);
      } else {
        Navigator.pushReplacementNamed(context, RoutesName.dashboardScreen);
      }
    }
  }

  Future<void> _loginWithEmailPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showDialog("Error", "Email is required", DialogType.error);
      return;
    }
    if (!_emailController.text.contains('@')) {
      _showDialog("Error", "Invalid email format", DialogType.error);
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showDialog("Error", "Password is required", DialogType.error);
      return;
    }

    setState(() => isEmailLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _updateFCMToken(userCredential.user!.uid);

      if (!mounted) return;
      _showDialog("Success", "Login Successful!", DialogType.success, onOk: () async {
        await _navigateAfterLogin(userCredential.user!);
      });
    } on FirebaseAuthException catch (e) {
      _showDialog("Error", e.message ?? "Login failed", DialogType.error);
    } catch (_) {
      _showDialog("Error", "An error occurred", DialogType.error);
    } finally {
      if (mounted) setState(() => isEmailLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => isGoogleLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isGoogleLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      await _updateFCMToken(userCredential.user!.uid);

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'role': 'user',
          'preferences': [],
          'favoriteQuotes': [],
          'fcmToken': await _fcmServices.getFCMToken(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      _showDialog("Success", "Google Sign-in Successful!", DialogType.success, onOk: () async {
        await _navigateAfterLogin(userCredential.user!);
      });
    } on FirebaseAuthException catch (e) {
      _showDialog("Error", e.message ?? 'Google login failed', DialogType.error);
    } catch (_) {
      _showDialog("Error", "An error occurred with Google Sign-In", DialogType.error);
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF7B61FF).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: animate ? 1 : 0,
              duration: const Duration(milliseconds: 1000),
              child: Padding(
                padding: const EdgeInsets.only(left: 34, top: 85, right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 4,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: AnimatedOpacity(
                  opacity: animate ? 1 : 0,
                  duration: const Duration(milliseconds: 1000),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 150),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white12),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildInputField(_emailController, 'Enter your email', 'email.svg'),
                              const SizedBox(height: 30),
                              _buildPasswordField(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isChecked,
                                          onChanged: (value) => setState(() => isChecked = value!),
                                          checkColor: Colors.black,
                                          activeColor: Colors.green.shade400,
                                        ),
                                        Flexible(
                                          child: Text(
                                            "Remember me",
                                            style: const TextStyle(color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(context, RoutesName.forgotPasswordScreen),
                                    child: const Text("Forgot Password?", style: TextStyle(color: Colors.white70)),
                                  ),
                                ],
                              ),
                              _loginButton(),
                              const SizedBox(height: 20),
                              const Center(
                                child: Text("Or", style: TextStyle(color: Colors.white54, fontSize: 16)),
                              ),
                              _googleSignInButton(),
                              _registerRedirect(),
                              const SizedBox(height: 20),
                              // _debugButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, String icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/icon/$icon',
            width: 20,
            height: 20,
            color: Colors.white,
          ),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/icon/password.svg',
            width: 20,
            height: 20,
            color: Colors.white,
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => isPasswordVisible = !isPasswordVisible),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              isPasswordVisible ? 'assets/icon/eye-open.svg' : 'assets/icon/eye-slash.svg',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
        ),
        hintText: 'Enter your password',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: isEmailLoading ? null : _loginWithEmailPassword,
        child: isEmailLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Login",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: isGoogleLoading ? null : _signInWithGoogle,
        child: isGoogleLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icon/google-g.svg',
              width: 30,
              height: 30,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: const Text(
                "Continue with Google",
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerRedirect() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            "Don't have an account?",
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, RoutesName.registerScreen),
          child: const Text(
            "Create an account",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
