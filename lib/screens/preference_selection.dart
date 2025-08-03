import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/models/preference_model.dart';
import 'package:manshi/utils/debug_utils.dart';

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

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    try {
      print('Loading preferences...');
      final allPreferences = await FirestoreService.getAllPreferences();
      print('Loaded ${allPreferences.length} preferences');
      setState(() {
        preferences = allPreferences;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading preferences: $e');
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, RoutesName.loginScreen);
                },
                child: SvgPicture.asset(
                  'assets/icon/chevron-backward.svg',
                  height: 40,
                  width: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Select all topics that motivates you",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : preferences.isEmpty
                        ? const Center(
                            child: Text(
                              'No preferences available',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 3,
                            children: preferences.map((preference) {
                              final isSelected = selectedPreferences.contains(preference.id);
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
                                    color: isSelected ? Colors.white : Colors.grey[900],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    preference.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
              ),
              const SizedBox(height: 30),
              // Debug button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => DebugUtils.debugFirebaseConnection(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                  ),
                  child: const Text("Debug Firebase Connection"),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedPreferences.isNotEmpty && !isSaving
                      ? savePreferences
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey[900]!.withOpacity(0.3);
                        }
                        return Colors.grey[900];
                      },
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Save",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
