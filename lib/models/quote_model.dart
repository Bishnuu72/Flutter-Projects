import 'package:cloud_firestore/cloud_firestore.dart';

class QuoteModel {
  final String id;
  final String text;
  final String author;
  final String category;
  final List<String> categories;
  final List<String> preferences;
  final DateTime createdAt;

  QuoteModel({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.categories,
    required this.preferences,
    required this.createdAt,
  });

  factory QuoteModel.fromMap(String id, Map<String, dynamic> map) {
    return QuoteModel(
      id: id,
      text: map['text'] ?? '',
      author: map['author'] ?? '',
      category: map['category'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      preferences: List<String>.from(map['preferences'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
      'category': category,
      'categories': categories,
      'preferences': preferences,
      'createdAt': createdAt,
    };
  }

  QuoteModel copyWith({
    String? id,
    String? text,
    String? author,
    String? category,
    List<String>? categories,
    List<String>? preferences,
    DateTime? createdAt,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      categories: categories ?? this.categories,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 