import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteCategory {
  medical,
  milestone,
  general,
}

class NoteEntry {
  final String id;
  final String babyId;
  final String title;
  final String content;
  final NoteCategory category;
  final List<String> tags;
  final bool isImportant;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteEntry({
    required this.id,
    required this.babyId,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.isImportant,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteEntry.fromMap(Map<String, dynamic> map, String id) {
    return NoteEntry(
      id: id,
      babyId: map['babyId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: NoteCategory.values[map['category'] ?? 2],
      tags: List<String>.from(map['tags'] ?? []),
      isImportant: map['isImportant'] ?? false,
      attachments: map['attachments'] != null
          ? List<String>.from(map['attachments'])
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'babyId': babyId,
      'title': title,
      'content': content,
      'category': category.index,
      'tags': tags,
      'isImportant': isImportant,
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  NoteEntry copyWith({
    String? id,
    String? babyId,
    String? title,
    String? content,
    NoteCategory? category,
    List<String>? tags,
    bool? isImportant,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteEntry(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isImportant: isImportant ?? this.isImportant,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}