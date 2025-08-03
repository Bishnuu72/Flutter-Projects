import 'package:cloud_firestore/cloud_firestore.dart';

class PreferenceModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final DateTime createdAt;

  PreferenceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory PreferenceModel.fromMap(String id, Map<String, dynamic> map) {
    return PreferenceModel(
      id: id,
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'createdAt': createdAt,
    };
  }

  PreferenceModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return PreferenceModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 