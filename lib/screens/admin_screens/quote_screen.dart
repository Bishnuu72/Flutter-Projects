import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manshi/models/quote_model.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/firebase_auth/fcm_services.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String? selectedCategory;
  List<String> categories = [];

  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _quoteController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuoteCategories();
  }

  Future<void> _fetchQuoteCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('type', isEqualTo: 'Quotes') // ensure this field exists in DB
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

  Future<void> _saveQuote() async {
    if (selectedCategory == null) {
      _showDialog("Error", "Please select a category", DialogType.error);
      return;
    }
    if (_authorController.text.trim().isEmpty) {
      _showDialog("Error", "Please enter author name", DialogType.error);
      return;
    }
    if (_quoteController.text.trim().isEmpty) {
      _showDialog("Error", "Please enter a quote", DialogType.error);
      return;
    }

    setState(() => isLoading = true);

    try {
      final quote = QuoteModel(
        id: '',
        text: _quoteController.text.trim(),
        author: _authorController.text.trim(),
        category: selectedCategory!,
        categories: [selectedCategory!],
        preferences: [selectedCategory!],
        createdAt: DateTime.now(),
      );

      final docRef = await FirestoreService.createQuote(quote);

      final updatedQuote = quote.copyWith(id: docRef.id);
      await _sendNotificationToUsers(updatedQuote);

      if (!mounted) return;
      _showDialog(
        "Success",
        "Quote added successfully!",
        DialogType.success,
        onOk: () {
          Navigator.pop(context);
        },
      );
    } catch (e) {
      _showDialog("Error", "Failed to save quote: $e", DialogType.error);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _sendNotificationToUsers(QuoteModel quote) async {
    try {
      final tokens = await FirestoreService.getFCMTokensByPreferences(quote.preferences);

      if (tokens.isNotEmpty) {
        await FCMServices.sendNotificationToMultipleTokens(
          tokens: tokens,
          title: "New Motivational Quote",
          body: "Check out this inspiring quote: ${quote.text.substring(0, quote.text.length > 50 ? 50 : quote.text.length)}...",
          data: {
            'type': 'new_quote',
            'quoteId': quote.id,
            'category': quote.category,
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
        title: const Text(
          'Add Quote',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Category:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: Colors.grey[900],
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Author Name:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _authorController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Author Name',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quote:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quoteController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write a quote',
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isLoading ? null : _saveQuote,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
