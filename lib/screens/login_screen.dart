import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/firebase_auth/fcm_services.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/utils/debug_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isChecked = false;
  bool isPasswordVisible = false;
  bool isEmailLoading = false;
  bool isGoogleLoading = false;

  final _firestore = FirebaseFirestore.instance;
  final FCMServices _fcmServices = FCMServices();

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
      backgroundColor: Colors.black,
      body: Stack(children: [
        Container(
          padding: const EdgeInsets.only(left: 80, top: 150),
          child: const Text(
            "Welcome Back!",
            style: TextStyle(color: Colors.white, fontSize: 33),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.3,
            right: 35,
            left: 35,
          ),
          child: ListView(
            children: [
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Enter your email', 'email.svg'),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                obscureText: !isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: _passwordInputDecoration(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) => setState(() => isChecked = value!),
                      checkColor: Colors.white,
                      activeColor: Colors.grey[700],
                    ),
                    const Text("Remember me", style: TextStyle(color: Colors.white)),
                  ]),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, RoutesName.forgotPasswordScreen),
                    child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              _loginButton(),
              const SizedBox(height: 20),
              const Center(
                child: Text("Or", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              _googleSignInButton(),
              _registerRedirect(),
              const SizedBox(height: 20),
              _debugButton(),
            ],
          ),
        ),
      ]),
    );
  }

  InputDecoration _inputDecoration(String hintText, String iconName) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          'assets/icon/$iconName',
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      ),
      fillColor: Colors.grey[900],
      filled: true,
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  InputDecoration _passwordInputDecoration() {
    return InputDecoration(
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
      fillColor: Colors.grey[900],
      filled: true,
      hintText: 'Enter your password',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _loginButton() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(10)),
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: isEmailLoading ? null : _loginWithEmailPassword,
        child: isEmailLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _googleSignInButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(10)),
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
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text("Google", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _registerRedirect() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, RoutesName.registerScreen),
            child: const Text("Create an account", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _debugButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => DebugUtils.debugFirebaseConnection(context),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[400],
        ),
        child: const Text("Debug Firebase Connection"),
      ),
    );
  }
}
