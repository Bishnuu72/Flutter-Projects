import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderType { daily, weekly }
enum ContentType { quote, healthTip, both }

class ReminderModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final ReminderType type;
  final ContentType contentType;
  final List<String> categories;
  final int hour;
  final int minute;
  final int? dayOfWeek; // Only for weekly reminders (1-7, where 1 is Monday)
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.contentType,
    required this.categories,
    required this.hour,
    required this.minute,
    this.dayOfWeek,
    required this.isActive,
    required this.createdAt,
    this.lastTriggered,
  });

  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == 'ReminderType.${map['type']}',
        orElse: () => ReminderType.daily,
      ),
      contentType: ContentType.values.firstWhere(
        (e) => e.toString() == 'ContentType.${map['contentType']}',
        orElse: () => ContentType.quote,
      ),
      categories: List<String>.from(map['categories'] ?? []),
      hour: map['hour'] ?? 9,
      minute: map['minute'] ?? 0,
      dayOfWeek: map['dayOfWeek'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastTriggered: (map['lastTriggered'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'contentType': contentType.toString().split('.').last,
      'categories': categories,
      'hour': hour,
      'minute': minute,
      'dayOfWeek': dayOfWeek,
      'isActive': isActive,
      'createdAt': createdAt,
      'lastTriggered': lastTriggered,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    ReminderType? type,
    ContentType? contentType,
    List<String>? categories,
    int? hour,
    int? minute,
    int? dayOfWeek,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      contentType: contentType ?? this.contentType,
      categories: categories ?? this.categories,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }
} 