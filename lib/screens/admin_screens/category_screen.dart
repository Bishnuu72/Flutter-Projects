import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedType = 'Quotes';
  bool _isLoading = false;

  List<DocumentSnapshot> _allPreferences = [];
  List<String> _selectedPreferences = [];

  File? _selectedImage;
  String? _uploadedImageUrl;

  // Configure your Cloudinary credentials
  final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dg3uu7mtg/image/upload'; // <-- Replace
  final uploadPreset = 'category_image'; // <-- Replace

  @override
  void initState() {
    super.initState();
    _fetchPreferences();
  }

  Future<void> _fetchPreferences() async {
    final snapshot = await FirebaseFirestore.instance.collection('preferences').get();
    setState(() {
      _allPreferences = snapshot.docs;
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final resData = jsonDecode(responseBody);
        return resData['secure_url'];
      } else {
        print('Upload failed: $responseBody');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _saveCategory() async {
    if (_categoryController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedImage == null ||
        _selectedPreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields, upload image, and select preferences.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      if (imageUrl == null) {
        throw Exception('Image upload failed');
      }

      final categoryData = {
        'name': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'preferences': _selectedPreferences,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('categories').add(categoryData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category saved successfully!')),
      );

      _categoryController.clear();
      _descriptionController.clear();
      _selectedPreferences.clear();
      setState(() {
        _selectedType = 'Quotes';
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTypeButton(String type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[800] : Colors.transparent,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(type, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceChip(DocumentSnapshot doc) {
    final name = doc['name'] ?? '';
    final isSelected = _selectedPreferences.contains(name);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPreferences.remove(name);
          } else {
            _selectedPreferences.add(name);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[700] : Colors.transparent,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Category Name:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter category name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter category description',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Background Image:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Center(
                    child: Text(
                      'Tap to upload image',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Category Type:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildTypeButton("Quotes"),
                  const SizedBox(width: 10),
                  _buildTypeButton("Health"),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Select Preferences:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                children: _allPreferences.map(_buildPreferenceChip).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
