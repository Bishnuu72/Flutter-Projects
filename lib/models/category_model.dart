import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;  // This holds your image URL or icon URL
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl
    ,
    required this.createdAt,
  });

  /// Getter alias for icon to be used as imageUrl in UI
  // String get imageUrl => icon;

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: icon ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
