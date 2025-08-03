import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> preferences;
  final List<String> favoriteQuotes;
  final DateTime createdAt;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.preferences,
    required this.favoriteQuotes,
    required this.createdAt,
    this.fcmToken,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      preferences: List<String>.from(map['preferences'] ?? []),
      favoriteQuotes: List<String>.from(map['favoriteQuotes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: map['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'preferences': preferences,
      'favoriteQuotes': favoriteQuotes,
      'createdAt': createdAt,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    List<String>? preferences,
    List<String>? favoriteQuotes,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      favoriteQuotes: favoriteQuotes ?? this.favoriteQuotes,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
} 