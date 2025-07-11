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

  final _formKey = GlobalKey<FormState>();

  Future<void> _loginWithEmailPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showError("Email is required");
      return;
    }
    if (!_emailController.text.contains('@')) {
      _showError("Invalid email format");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError("Password is required");
      return;
    }

    setState(() => isEmailLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        Navigator.pushNamed(context, RoutesName.preferenceSelection);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed");
    } catch (_) {
      _showError("An error occurred");
    } finally {
      setState(() => isEmailLoading = false);
    }
  }

  Future<void> signInWithGoogleOnlyIfUserExists() async {
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

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pushNamed(context, RoutesName.preferenceSelection);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Google login failed');
    } catch (_) {
      _showError("An error occurred with Google Sign-In");
    } finally {
      setState(() => isGoogleLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/icon/email.svg',
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                    fillColor: Colors.grey[900],
                    filled: true,
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
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
                          isPasswordVisible
                              ? 'assets/icon/eye-open.svg'
                              : 'assets/icon/eye-slash.svg',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    fillColor: Colors.grey[900],
                    filled: true,
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
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
                        onPressed: () {},
                        child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: isEmailLoading ? null : _loginWithEmailPassword,
                    child: isEmailLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Or",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                ),
                Container(
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
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
