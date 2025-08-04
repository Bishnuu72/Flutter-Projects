import 'package:cloud_firestore/cloud_firestore.dart';

class HealthTipModel {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final String preferenceId;
  final DateTime createdAt;

  HealthTipModel({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.preferenceId,
    required this.createdAt,
  });

  /// Factory method to create HealthTipModel from Firestore Map
  factory HealthTipModel.fromMap(String id, Map<String, dynamic> map) {
    return HealthTipModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      categoryId: map['categoryId'] ?? '',
      preferenceId: map['preferenceId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'preferenceId': preferenceId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Clone the model with optional updated fields
  HealthTipModel copyWith({
    String? id,
    String? title,
    String? content,
    String? categoryId,
    String? preferenceId,
    DateTime? createdAt,
  }) {
    return HealthTipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      preferenceId: preferenceId ?? this.preferenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
