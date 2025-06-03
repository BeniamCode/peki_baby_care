import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteCategory {
  medical,
  milestone,
  general,
}

class Note {
  final String id;
  final String userId;
  final String babyId;
  final String title;
  final String content;
  final NoteCategory category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.babyId,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'babyId': babyId,
      'title': title,
      'content': content,
      'category': category.index,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, String id) {
    return Note(
      id: id,
      userId: map['userId'] ?? '',
      babyId: map['babyId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: NoteCategory.values[map['category'] ?? 2],
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Note copyWith({
    String? id,
    String? userId,
    String? babyId,
    String? title,
    String? content,
    NoteCategory? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      babyId: babyId ?? this.babyId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}