import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DebugUtils {
  static Future<void> debugFirebaseConnection(BuildContext context) async {
    try {
      // Test Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      print('Current user: ${currentUser?.uid ?? 'No user logged in'}');
      
      // Test Firestore connection
      final testDoc = await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .get();
      print('Firestore connection test: ${testDoc.exists ? 'Success' : 'Document not found but connection works'}');
      
      // Test users collection
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      print('Users collection: ${usersSnapshot.docs.length} documents found');
      
      // Test categories collection
      final categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
      print('Categories collection: ${categoriesSnapshot.docs.length} documents found');
      
      // Test preferences collection
      final preferencesSnapshot = await FirebaseFirestore.instance.collection('preferences').get();
      print('Preferences collection: ${preferencesSnapshot.docs.length} documents found');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug info logged to console'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Firebase debug error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  static Future<void> debugUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        print('User data for $userId:');
        print('  Name: ${userData['name']}');
        print('  Email: ${userData['email']}');
        print('  Role: ${userData['role']}');
        print('  Preferences: ${userData['preferences']}');
        print('  Created at: ${userData['createdAt']}');
      } else {
        print('User document does not exist for $userId');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
} 