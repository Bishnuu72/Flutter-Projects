import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/models/preference_model.dart';

class PreferenceSelection extends StatefulWidget {
  const PreferenceSelection({super.key});

  @override
  State<PreferenceSelection> createState() => _PreferenceSelectionState();
}

class _PreferenceSelectionState extends State<PreferenceSelection> {
  List<PreferenceModel> preferences = [];
  final Set<String> selectedPreferences = {};
  bool isLoading = true;
  bool isSaving = false;

  // Updated map to assign icons based on preference name matching the screenshot
  final Map<String, IconData> iconMap = {
    'Positive thinking': Icons.thumb_up,
    'Inspiration': Icons.lightbulb_outline,
    'Hard times': Icons.hourglass_bottom,
    'Love': Icons.favorite,
    'Faith & Spirituality': Icons.self_improvement,
    'Productivity': Icons.timer,
    'Relationships': Icons.people,
    'Stress & Anxiety': Icons.healing,
    'Working out': Icons.fitness_center,
    'Self-esteem': Icons.star,
    'Achieving goals': Icons.check_circle,
    'Letting go': Icons.delete_outline,
    // Add more mappings if you have additional preferences in Firestore
  };

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    try {
      final allPreferences = await FirestoreService.getAllPreferences();
      setState(() {
        preferences = allPreferences;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load preferences: $e')),
        );
      }
    }
  }

  Future<void> savePreferences() async {
    setState(() {
      isSaving = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirestoreService.updateUserPreferences(uid, selectedPreferences.toList());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
        Navigator.pushReplacementNamed(context, RoutesName.dashboardScreen);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save preferences: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black87],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RoutesName.loginScreen);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Select all topics that motivates you",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "You can select multiple topics",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                      : preferences.isEmpty
                      ? const Center(
                    child: Text(
                      'No preferences available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 3,
                    children: preferences.map((preference) {
                      final isSelected = selectedPreferences.contains(preference.id);
                      final icon = iconMap[preference.name] ?? Icons.help_outline; // Default icon if not mapped
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedPreferences.remove(preference.id);
                            } else {
                              selectedPreferences.add(preference.id);
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.green : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                color: isSelected ? Colors.white : Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                preference.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB2FF59), Color(0xFF69F0AE)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: selectedPreferences.isNotEmpty && !isSaving
                          ? savePreferences
                          : null,
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                        "Get started",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}