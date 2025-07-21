import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/firebase_auth/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isChecked = false;
  bool isPasswordVisible = false;
  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RegExp _passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

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
        _showDialog('Error',
            'Password must be at least 8 characters,\ninclude uppercase, lowercase, number and special character',
            DialogType.error);
        return;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'user', // ✅ Added role field
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showDialog('Success', 'Registered successfully!', DialogType.success, onOk: () {
        Navigator.pushNamed(context, RoutesName.loginScreen);
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
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 85),
            child: const Text(
              "Start your wellness journey today.",
              style: TextStyle(color: Colors.white, fontSize: 33),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.25,
              right: 35,
              left: 35,
            ),
            child: ListView(
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Enter your name', 'user.svg'),
                ),
                const SizedBox(height: 30),
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
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.grey[700],
                    ),
                    const Text("Remember me", style: TextStyle(color: Colors.white)),
                  ],
                ),
                _submitButton(),
                const SizedBox(height: 20),
                const Center(child: Text("Or", style: TextStyle(color: Colors.white, fontSize: 16))),
                _googleSignInButton(),
                _loginRedirect()
              ],
            ),
          ),
        ],
      ),
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
        onTap: () {
          setState(() {
            isPasswordVisible = !isPasswordVisible;
          });
        },
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
      fillColor: Colors.grey.shade900,
      filled: true,
      hintText: 'Enter your password',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: isLoading ? null : _registerUser,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
          "Sign up",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: () async {
          final userCredential = await AuthService().signInWithGoogle();
          if (!mounted) return;
          if (userCredential != null) {
            _showDialog('Success', 'Signed in as ${userCredential.user!.displayName}', DialogType.success);
          } else {
            _showDialog('Error', 'Google sign-in failed', DialogType.error);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icon/google-g.svg', width: 40, height: 40, color: Colors.white),
            const SizedBox(width: 10),
            const Text("Google", style: TextStyle(color: Colors.white, fontSize: 18)),
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
          const Text("Already have an account?", style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, RoutesName.loginScreen);
            },
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
