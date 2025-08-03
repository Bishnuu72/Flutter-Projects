import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manshi/models/health_tip_model.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/firebase_auth/fcm_services.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  String? selectedCategory;
  List<String> categories = [];
  final TextEditingController _tipsController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHealthCategories();
  }

  Future<void> _fetchHealthCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('type', isEqualTo: 'Health')
          .get();
      setState(() {
        categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      _showDialog("Error", "Failed to load categories: $e", DialogType.error);
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

  Future<void> _saveHealthTip() async {
    if (selectedCategory == null) {
      _showDialog("Error", "Please select a category", DialogType.error);
      return;
    }
    if (_tipsController.text.trim().isEmpty) {
      _showDialog("Error", "Please enter health tip content", DialogType.error);
      return;
    }

    setState(() => isLoading = true);

    try {
      final tip = HealthTipModel(
        id: '',
        title: selectedCategory!,
        content: _tipsController.text.trim(),
        categoryId: selectedCategory!,
        preferenceId: selectedCategory!,
        createdAt: DateTime.now(),
      );

      final savedTip = await FirestoreService.createHealthTip(tip);

      await _sendNotificationToUsers(savedTip);

      if (!mounted) return;
      _showDialog(
        "Success",
        "Health tip added successfully!",
        DialogType.success,
        onOk: () {
          Navigator.pop(context);
        },
      );
    } catch (e) {
      _showDialog("Error", "Failed to save health tip: $e", DialogType.error);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _sendNotificationToUsers(HealthTipModel tip) async {
    try {
      final tokens = await FirestoreService.getFCMTokensByPreferences([tip.preferenceId]);

      if (tokens.isNotEmpty) {
        await FCMServices.sendNotificationToMultipleTokens(
          tokens: tokens,
          title: "New Health Tip",
          body: "Wellness tip: ${tip.content.substring(0, tip.content.length > 50 ? 50 : tip.content.length)}...",
          data: {
            'type': 'new_health_tip',
            'tipId': tip.id,
            'category': tip.categoryId,
          },
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Health Tip', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Category:', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: Colors.grey[900],
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(border: InputBorder.none),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: Colors.white)));
                }).toList(),
                onChanged: (v) => setState(() => selectedCategory = v),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Health Tip Content:', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _tipsController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write health tip',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: isLoading ? null : _saveHealthTip,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
