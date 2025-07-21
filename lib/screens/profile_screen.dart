import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:manshi/core/route_config/routes_name.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  String? profileImageUrl;
  String? displayName;

  final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dg3uu7mtg/image/upload';
  final uploadPreset = 'wellness_app_upload';

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists) {
          setState(() {
            displayName = doc.data()?['name'] ?? 'No Name';
            profileImageUrl = doc.data()?['profileImage'];
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false);
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      backgroundColor: Colors.grey[900],
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Upload photo', style: TextStyle(color: Colors.white)),
                onTap: _uploadPhoto,
              ),
              if (profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                  onTap: _deletePhoto,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadPhoto() async {
    Navigator.pop(context);

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final resData = jsonDecode(responseBody);
        final downloadUrl = resData['secure_url'];

        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'profileImage': downloadUrl,
        });

        setState(() => profileImageUrl = downloadUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed. Please try again.')),
        );
      }
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading image.')),
      );
    }
  }

  Future<void> _deletePhoto() async {
    Navigator.pop(context);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'profileImage': null,
      });
      setState(() => profileImageUrl = null);
    } catch (e) {
      print('Error removing profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error removing profile image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? 'No Email';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icon/chevron-backward.svg',
            color: Colors.grey,
            height: 40,
            width: 40,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _profileHeader(email),
            const SizedBox(height: 30),
            _sectionTitle("MAKE IT YOURS"),
            _singleButtonContainer(Icons.menu_book, "Content preferences", () {}),
            const SizedBox(height: 20),
            _sectionTitle('ACCOUNT'),
            _singleButtonContainer(Icons.edit, "Theme", () {}),
            _singleButtonContainer(Icons.password, "Forgot Password", () {
              Navigator.pushNamed(context, RoutesName.forgotPasswordScreen);
            }),
            _singleButtonContainer(Icons.lock_reset, "Change Password", () {
              Navigator.pushNamed(context, RoutesName.changePasswordScreen);
            }),
            _singleButtonContainer(Icons.logout, "Logout", _logout),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader(String email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showImageOptions,
            child: profileImageUrl != null
                ? CircleAvatar(
              key: ValueKey(profileImageUrl),
              backgroundImage: NetworkImage(profileImageUrl!),
              radius: 35,
            )
                : CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Text(
                (displayName?.isNotEmpty ?? false) ? displayName![0].toUpperCase() : "?",
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName ?? 'No Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _singleButtonContainer(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: onTap,
      ),
    );
  }
}
