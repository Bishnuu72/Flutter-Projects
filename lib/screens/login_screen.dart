import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manshi/core/route_config/routes_name.dart';

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

  String selectedRole = 'user';

  final _formKey = GlobalKey<FormState>();

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

      if (userCredential.user != null) {
        if (!mounted) return;
        _showDialog("Success", "Login Successful!", DialogType.success, onOk: () {
          if (selectedRole == 'user') {
            Navigator.pushNamed(context, RoutesName.preferenceSelection);
          } else {
            Navigator.pushNamed(context, RoutesName.adminDashboardScreen);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      _showDialog("Error", e.message ?? "Login failed", DialogType.error);
    } catch (_) {
      _showDialog("Error", "An error occurred", DialogType.error);
    } finally {
      if (mounted) setState(() => isEmailLoading = false);
    }
  }

  Future<void> signInWithGoogleOnlyIfUserExists() async {
    setState(() => isGoogleLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => isGoogleLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      _showDialog("Success", "Google Sign-in Successful!", DialogType.success, onOk: () {
        if (selectedRole == 'user') {
          Navigator.pushNamed(context, RoutesName.preferenceSelection);
        } else {
          Navigator.pushNamed(context, RoutesName.adminDashboardScreen);
        }
      });
    } on FirebaseAuthException catch (e) {
      _showDialog("Error", e.message ?? 'Google login failed', DialogType.error);
    } catch (_) {
      _showDialog("Error", "An error occurred with Google Sign-In", DialogType.error);
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
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
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    const Text("Role:", style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'admin',
                          groupValue: selectedRole,
                          onChanged: (value) => setState(() => selectedRole = value!),
                          activeColor: Colors.white,
                        ),
                        const Text("Admin", style: TextStyle(color: Colors.white)),
                        Radio<String>(
                          value: 'user',
                          groupValue: selectedRole,
                          onChanged: (value) => setState(() => selectedRole = value!),
                          activeColor: Colors.white,
                        ),
                        const Text("User", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
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
                      onPressed: () {
                        Navigator.pushNamed(context, RoutesName.forgotPasswordScreen);
                      },
                      child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                _loginButton(),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Or",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                _googleSignInButton(),
                _registerRedirect()
              ],
            ),
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
            : const Text(
          "Login",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
        onPressed: isGoogleLoading ? null : signInWithGoogleOnlyIfUserExists,
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
}
