import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmNewPassController = TextEditingController();

  bool isCurrentVisible = false;
  bool isNewVisible = false;
  bool isConfirmVisible = false;
  bool isLoading = false;

  void _changePassword() async {
    final currentPass = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmNewPassController.text.trim();

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showDialog('Error', 'All fields are required', DialogType.error);
      return;
    }

    if (newPass.length < 8) {
      _showDialog('Error', 'New password must be at least 8 characters', DialogType.error);
      return;
    }

    if (newPass != confirmPass) {
      _showDialog('Error', 'Passwords do not match', DialogType.error);
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(email: user!.email!, password: currentPass);
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPass);
      if (!mounted) return;
      _showDialog('Success', 'Password changed successfully!', DialogType.success, onOk: () {
        Navigator.pop(context);
      });
    } on FirebaseAuthException catch (e) {
      _showDialog('Error', e.message ?? 'Something went wrong', DialogType.error);
    } catch (_) {
      _showDialog('Error', 'An unexpected error occurred', DialogType.error);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showDialog(String title, String desc, DialogType type, {VoidCallback? onOk}) {
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 20),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            _passwordField('Enter current password', _currentPassController, isCurrentVisible, () {
              setState(() => isCurrentVisible = !isCurrentVisible);
            }),
            const SizedBox(height: 30),
            _passwordField('Enter new password', _newPassController, isNewVisible, () {
              setState(() => isNewVisible = !isNewVisible);
            }),
            const SizedBox(height: 30),
            _passwordField('Confirm new password', _confirmNewPassController, isConfirmVisible, () {
              setState(() => isConfirmVisible = !isConfirmVisible);
            }),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(10)),
              height: 50,
              child: TextButton(
                onPressed: isLoading ? null : _changePassword,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Update Password",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(String hintText, TextEditingController controller, bool isVisible, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset('assets/icon/password.svg', width: 20, height: 20, color: Colors.white),
        ),
        suffixIcon: GestureDetector(
          onTap: toggle,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              isVisible ? 'assets/icon/eye-open.svg' : 'assets/icon/eye-slash.svg',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
        ),
        fillColor: Colors.grey[900],
        filled: true,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
