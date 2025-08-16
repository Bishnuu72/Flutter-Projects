import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/preference_model.dart';
import '../models/quote_model.dart';
import '../models/health_tip_model.dart';
import '../models/reminder_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------- User ----------------------
  static Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  static Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) return UserModel.fromMap(doc.id, doc.data()!);
    return null;
  }

  static Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<void> updateUserPreferences(String userId, List<String> preferences) async {
    await _firestore.collection('users').doc(userId).update({'preferences': preferences});
  }

  static Future<void> updateUserFCMToken(String userId, String fcmToken) async {
    await _firestore.collection('users').doc(userId).update({'fcmToken': fcmToken});
  }

  static Future<List<String>> getFCMTokensByPreferences(List<String> preferences) async {
    final snapshot = await _firestore
        .collection('users')
        .where('preferences', arrayContainsAny: preferences)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['fcmToken'])
        .where((token) => token != null && token.isNotEmpty)
        .cast<String>()
        .toList();
  }

  static Future<List<String>> getFCMTokensByUserIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final snapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['fcmToken'])
        .where((token) => token != null && token.isNotEmpty)
        .cast<String>()
        .toList();
  }

  static Future<void> toggleFavoriteQuote(String userId, String quoteId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    final user = UserModel.fromMap(userDoc.id, userDoc.data()!);
    final favoriteQuotes = List<String>.from(user.favoriteQuotes);

    if (favoriteQuotes.contains(quoteId)) {
      favoriteQuotes.remove(quoteId);
    } else {
      favoriteQuotes.add(quoteId);
    }

    await _firestore.collection('users').doc(userId).update({'favoriteQuotes': favoriteQuotes});
  }

  static Future<bool> hasUnreadNotificationsForUser(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // ---------------------- Reminder ----------------------
  static Future<List<ReminderModel>> getUserReminders(String userId) async {
    final snapshot = await _firestore
        .collection('reminders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReminderModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<void> createReminder(ReminderModel reminder) async {
    await _firestore.collection('reminders').add(reminder.toMap());
  }

  static Future<void> updateReminder(String reminderId, Map<String, dynamic> data) async {
    await _firestore.collection('reminders').doc(reminderId).update(data);
  }

  static Future<void> deleteReminder(String reminderId) async {
    await _firestore.collection('reminders').doc(reminderId).delete();
  }

  static Future<void> updateReminderLastTriggered(String reminderId) async {
    await _firestore.collection('reminders').doc(reminderId).update({
      'lastTriggered': DateTime.now(),
    });
  }

  // ---------------------- Categories ----------------------
  static Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<List<CategoryModel>> getQuoteCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .where('type', isEqualTo: 'Quotes')
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<List<CategoryModel>> getHealthCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .where('type', isEqualTo: 'Health')
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<void> createCategory(CategoryModel category) async {
    await _firestore.collection('categories').add(category.toMap());
  }

  static Future<void> updateCategory(String categoryId, Map<String, dynamic> data) async {
    await _firestore.collection('categories').doc(categoryId).update(data);
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  // ---------------------- Preferences ----------------------
  static Future<List<PreferenceModel>> getPreferencesByCategory(String categoryId) async {
    final snapshot = await _firestore
        .collection('preferences')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => PreferenceModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<List<PreferenceModel>> getAllPreferences() async {
    final snapshot = await _firestore.collection('preferences').get();
    return snapshot.docs.map((doc) => PreferenceModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<void> createPreference(PreferenceModel preference) async {
    await _firestore.collection('preferences').add(preference.toMap());
  }

  static Future<void> updatePreference(String preferenceId, Map<String, dynamic> data) async {
    await _firestore.collection('preferences').doc(preferenceId).update(data);
  }

  static Future<void> deletePreference(String preferenceId) async {
    await _firestore.collection('preferences').doc(preferenceId).delete();
  }

  // ---------------------- Quotes ----------------------
  static Future<List<QuoteModel>> getQuotes() async {
    final snapshot = await _firestore.collection('quotes').get();
    return snapshot.docs.map((doc) => QuoteModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<List<QuoteModel>> getQuotesByPreferences(List<String> preferences) async {
    final snapshot = await _firestore
        .collection('quotes')
        .where('preferences', arrayContainsAny: preferences)
        .get();
    return snapshot.docs.map((doc) => QuoteModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<List<QuoteModel>> getQuotesByCategory(String categoryName) async {
    log("category name: $categoryName");
    final snapshot = await _firestore
        .collection('quotes')
        .where('categories', arrayContains: categoryName)
        .get();
    log("category name: $categoryName, data: ${snapshot.docs}");
    return snapshot.docs.map((doc) => QuoteModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<List<QuoteModel>> getFavoriteQuotes(String userId) async {
    final user = await getUser(userId);
    if (user == null || user.favoriteQuotes.isEmpty) return [];

    final snapshot = await _firestore
        .collection('quotes')
        .where(FieldPath.documentId, whereIn: user.favoriteQuotes)
        .get();
    return snapshot.docs.map((doc) => QuoteModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<QuoteModel> createQuote(QuoteModel quote) async {
    final docRef = await _firestore.collection('quotes').add(quote.toMap());
    return quote.copyWith(id: docRef.id);
  }

  static Future<void> updateQuote(String quoteId, Map<String, dynamic> data) async {
    await _firestore.collection('quotes').doc(quoteId).update(data);
  }

  static Future<void> deleteQuote(String quoteId) async {
    await _firestore.collection('quotes').doc(quoteId).delete();
  }

  // ---------------------- Health Tips ----------------------
  static Future<List<HealthTipModel>> getHealthTips() async {
    final snapshot = await _firestore.collection('healthTips').get();
    return snapshot.docs.map((doc) => HealthTipModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<List<HealthTipModel>> getHealthTipsByCategory(String categoryId) async {
    final snapshot = await _firestore
        .collection('healthTips')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => HealthTipModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<List<HealthTipModel>> getHealthTipsByPreference(String preferenceId) async {
    final snapshot = await _firestore
        .collection('healthTips')
        .where('preferenceId', isEqualTo: preferenceId)
        .get();
    return snapshot.docs.map((doc) => HealthTipModel.fromMap(doc.id, doc.data())).toList();
  }

  static Future<HealthTipModel> createHealthTip(HealthTipModel healthTip) async {
    final docRef = await _firestore.collection('healthTips').add(healthTip.toMap());
    return healthTip.copyWith(id: docRef.id);
  }

  static Future<void> updateHealthTip(HealthTipModel healthTip) async {
    await _firestore.collection('healthTips').doc(healthTip.id).update(healthTip.toMap());
  }

  static Future<void> deleteHealthTip(String healthTipId) async {
    await _firestore.collection('healthTips').doc(healthTipId).delete();
  }

  // ---------------------- Auth / Role ----------------------
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Future<bool> isUserAdmin(String userId) async {
    final user = await getUser(userId);
    return user?.role == 'admin';
  }
}