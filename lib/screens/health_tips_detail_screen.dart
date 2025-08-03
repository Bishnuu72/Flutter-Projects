import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/models/health_tip_model.dart';
import 'package:manshi/models/user_model.dart';

class HealthTipsDetailScreen extends StatefulWidget {
  const HealthTipsDetailScreen({super.key});

  @override
  State<HealthTipsDetailScreen> createState() => _HealthTipsDetailScreenState();
}

class _HealthTipsDetailScreenState extends State<HealthTipsDetailScreen> {
  List<HealthTipModel> healthTips = [];
  List<HealthTipModel> allHealthTips = [];
  UserModel? currentUser;
  bool isLoading = true;
  bool showAllTips = false;

  @override
  void initState() {
    super.initState();
    loadHealthTips();
  }

  Future<void> loadHealthTips() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Load user data
        final userData = await FirestoreService.getUser(user.uid);
        setState(() {
          currentUser = userData;
        });

        // Load all health tips
        final allTipsData = await FirestoreService.getHealthTips();
        setState(() {
          allHealthTips = allTipsData;
        });

        // Load personalized health tips based on preferences
        if (userData != null && userData.preferences.isNotEmpty) {
          // For now, show all tips since we need to implement preference-based filtering
          // This can be enhanced later with more sophisticated filtering
          setState(() {
            healthTips = allTipsData;
            isLoading = false;
          });
        } else {
          setState(() {
            healthTips = allTipsData;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load health tips: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Health Tips'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showAllTips = !showAllTips;
                healthTips = showAllTips ? allHealthTips : allHealthTips;
              });
            },
            icon: Icon(
              showAllTips ? Icons.person : Icons.public,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : healthTips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No health tips available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for new health tips',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (currentUser?.preferences.isNotEmpty == true && !showAllTips)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Showing health tips for your wellness journey',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: healthTips.length,
                        itemBuilder: (context, index) {
                          final tip = healthTips[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.health_and_safety,
                                      color: Colors.green[400],
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tip.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  tip.content,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}