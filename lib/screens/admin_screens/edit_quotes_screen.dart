import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:manshi/models/quote_model.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class EditQuoteScreen extends StatefulWidget {
  final QuoteModel? quote; // nullable to support create/edit both

  const EditQuoteScreen({super.key, this.quote});

  @override
  State<EditQuoteScreen> createState() => _EditQuoteScreenState();
}

class _EditQuoteScreenState extends State<EditQuoteScreen> {
  String? selectedCategory;
  List<String> categories = [];

  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _quoteController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.quote != null) {
      selectedCategory = widget.quote!.category;
      _authorController.text = widget.quote!.author;
      _quoteController.text = widget.quote!.text;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('type', isEqualTo: 'Quotes')
          .get();

      setState(() {
        categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      _showDialog('Error', 'Failed to load categories: $e', DialogType.error);
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
      _showDialog('Error', 'Please select a category', DialogType.error);
      return;
    }
    if (_authorController.text.trim().isEmpty) {
      _showDialog('Error', 'Please enter author name', DialogType.error);
      return;
    }
    if (_quoteController.text.trim().isEmpty) {
      _showDialog('Error', 'Please enter a quote', DialogType.error);
      return;
    }

    setState(() => isLoading = true);

    try {
      final now = DateTime.now();
      final isEditing = widget.quote != null;

      final quote = QuoteModel(
        id: isEditing ? widget.quote!.id : '', // keep ID if editing
        text: _quoteController.text.trim(),
        author: _authorController.text.trim(),
        category: selectedCategory!,
        categories: [selectedCategory!],
        preferences: [selectedCategory!],
        createdAt: isEditing ? widget.quote!.createdAt : now,
      );

      if (isEditing) {
        await FirestoreService.updateQuote(
          quote.id,
          {
            'text': quote.text,
            'author': quote.author,
            'category': quote.category,
            'preferences': quote.preferences,
            'categories': quote.categories,
            'createdAt': quote.createdAt,
          },
        );

      } else {
        final docRef = await FirestoreService.createQuote(quote);
        // Optionally update ID in model if needed
      }

      if (!mounted) return;
      _showDialog(
        'Success',
        isEditing ? 'Quote updated successfully!' : 'Quote added successfully!',
        DialogType.success,
        onOk: () {
          Navigator.pop(context, true); // pass true to refresh list
        },
      );
    } catch (e) {
      _showDialog('Error', 'Failed to save quote: $e', DialogType.error);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quote != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditing ? 'Edit Quote' : 'Add Quote',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
            const Text('Author Name:', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _authorController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Author Name',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Quote:', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isLoading ? null : _saveQuote,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
