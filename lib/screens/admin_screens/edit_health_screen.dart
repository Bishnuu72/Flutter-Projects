import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manshi/models/health_tip_model.dart';
import 'package:manshi/services/firestore_service.dart';

class EditHealthTipsScreen extends StatefulWidget {
  final HealthTipModel healthTip;

  const EditHealthTipsScreen({super.key, required this.healthTip});

  @override
  State<EditHealthTipsScreen> createState() => _EditHealthTipsScreenState();
}

class _EditHealthTipsScreenState extends State<EditHealthTipsScreen> {
  String? selectedCategory;
  List<String> categories = [];
  final TextEditingController _tipsController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.healthTip.title;
    _tipsController.text = widget.healthTip.content;
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

  Future<void> _updateHealthTip() async {
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
      final updatedTip = HealthTipModel(
        id: widget.healthTip.id,
        title: selectedCategory!,
        content: _tipsController.text.trim(),
        categoryId: selectedCategory!,
        preferenceId: selectedCategory!,
        createdAt: widget.healthTip.createdAt, // keep original date
      );

      await FirestoreService.updateHealthTip(updatedTip);

      if (!mounted) return;
      _showDialog(
        "Success",
        "Health tip updated successfully!",
        DialogType.success,
        onOk: () {
          Navigator.pop(context, true); // return true so list refreshes
        },
      );
    } catch (e) {
      _showDialog("Error", "Failed to update health tip: $e", DialogType.error);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Health Tip', style: TextStyle(color: Colors.white)),
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
                onPressed: isLoading ? null : _updateHealthTip,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
