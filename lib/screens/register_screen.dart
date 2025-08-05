import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/firebase_auth/auth_service.dart';
import 'package:manshi/firebase_auth/fcm_services.dart';
import 'package:manshi/services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool animate = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FCMServices _fcmServices = FCMServices();

  final RegExp _passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => animate = true);
    });
  }

  Future<void> _registerUser() async {
    setState(() => isLoading = true);
    try {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _showDialog('Error', 'All fields are required', DialogType.error);
        return;
      }

      if (!email.contains('@') || !email.contains('.')) {
        _showDialog('Error', 'Enter a valid email address', DialogType.error);
        return;
      }

      if (!_passwordRegExp.hasMatch(password)) {
        _showDialog(
          'Error',
          'Password must be at least 8 characters,\ninclude uppercase, lowercase, number and special character',
          DialogType.error,
        );
        return;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);
      final fcmToken = await _fcmServices.getFCMToken();

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'user',
        'preferences': [],
        'favoriteQuotes': [],
        'fcmToken': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showDialog('Success', 'Registered successfully!', DialogType.success,
          onOk: () {
            Navigator.pushNamed(context, RoutesName.preferenceSelection);
          });
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";
      if (e.code == 'email-already-in-use') {
        message = "Email already in use";
      } else if (e.code == 'weak-password') {
        message = "Password too weak";
      }
      _showDialog('Error', message, DialogType.error);
    } catch (e) {
      _showDialog('Error', "An unexpected error occurred", DialogType.error);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showDialog(String title, String desc, DialogType type,
      {VoidCallback? onOk}) {
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
            colors: [Color(0xFFEAE6F8), Color(0xFFF7F7F7)],
          ),
        ),
        child: Stack(
          children: [
            // Faded Circle Decoration (Top)
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
                      Color(0xFFCEB5FF).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Glass Header
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
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text(
                        "Start your wellness\njourney today.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          shadows: [
                            Shadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(1, 2))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Form container with animation
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: animate ? 1 : 0,
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 200),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(25),
                          border:
                          Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputField(_nameController,
                                'Enter your name', 'user.svg'),
                            const SizedBox(height: 20),
                            _buildInputField(_emailController,
                                'Enter your email', 'email.svg'),
                            const SizedBox(height: 20),
                            _buildPasswordField(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                  checkColor: Colors.white,
                                  activeColor: Colors.green.shade800,
                                ),
                                const Text("Remember me",
                                    style: TextStyle(color: Colors.black)),
                              ],
                            ),
                            _submitButton(),
                            const SizedBox(height: 10),
                            const Center(
                              child: Text("Or",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16)),
                            ),
                            _googleSignInButton(),
                            _loginRedirect()
                          ],
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

  Widget _buildInputField(
      TextEditingController controller, String hint, String icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/icon/$icon',
            width: 20,
            height: 20,
            color: Colors.black,
          ),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !isPasswordVisible,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/icon/password.svg',
            width: 20,
            height: 20,
            color: Colors.black,
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              isPasswordVisible
                  ? 'assets/icon/eye-open.svg'
                  : 'assets/icon/eye-slash.svg',
              width: 20,
              height: 20,
              color: Colors.black,
            ),
          ),
        ),
        hintText: 'Enter your password',
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFB2FF59), Color(0xFF69F0AE)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: isLoading ? null : _registerUser,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
          "Sign up",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: () async {
          final userCredential = await AuthService().signInWithGoogle();
          if (!mounted) return;
          if (userCredential != null) {
            _showDialog('Success',
                'Signed in as ${userCredential.user!.displayName}', DialogType.success);
          } else {
            _showDialog('Error', 'Google sign-in failed', DialogType.error);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icon/google-g.svg',
                width: 30, height: 30, color: Colors.black),
            const SizedBox(width: 10),
            const Text("Continue with Google",
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _loginRedirect() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account?",
              style: TextStyle(color: Colors.black)),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, RoutesName.loginScreen);
            },
            child: const Text("Login",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline)),
          )
        ],
      ),
    );
  }
}
