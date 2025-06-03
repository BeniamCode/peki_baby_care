import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteCategory { 
  milestone, 
  health, 
  behavior, 
  appointment, 
  memory, 
  other 
}

enum NotePriority { low, medium, high }

class NoteModel {
  final String id;
  final String babyId;
  final String title;
  final String content;
  final NoteCategory category;
  final NotePriority priority;
  final DateTime noteDate;
  final List<String>? tags;
  final List<String>? attachmentUrls; // for photos or documents
  final bool isPinned;
  final DateTime? reminderDate;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  NoteModel({
    required this.id,
    required this.babyId,
    required this.title,
    required this.content,
    required this.category,
    required this.priority,
    required this.noteDate,
    this.tags,
    this.attachmentUrls,
    required this.isPinned,
    this.reminderDate,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      babyId: map['babyId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: NoteCategory.values.firstWhere(
        (c) => c.toString().split('.').last == map['category'],
        orElse: () => NoteCategory.other,
      ),
      priority: NotePriority.values.firstWhere(
        (p) => p.toString().split('.').last == map['priority'],
        orElse: () => NotePriority.low,
      ),
      noteDate: (map['noteDate'] as Timestamp).toDate(),
      tags: map['tags'] != null 
          ? List<String>.from(map['tags']) 
          : null,
      attachmentUrls: map['attachmentUrls'] != null 
          ? List<String>.from(map['attachmentUrls']) 
          : null,
      isPinned: map['isPinned'] ?? false,
      reminderDate: map['reminderDate'] != null 
          ? (map['reminderDate'] as Timestamp).toDate() 
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      updatedBy: map['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'babyId': babyId,
      'title': title,
      'content': content,
      'category': category.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'noteDate': Timestamp.fromDate(noteDate),
      'tags': tags,
      'attachmentUrls': attachmentUrls,
      'isPinned': isPinned,
      'reminderDate': reminderDate != null 
          ? Timestamp.fromDate(reminderDate!) 
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'updatedAt': updatedAt != null 
          ? Timestamp.fromDate(updatedAt!) 
          : null,
      'updatedBy': updatedBy,
    };
  }

  NoteModel copyWith({
    String? id,
    String? babyId,
    String? title,
    String? content,
    NoteCategory? category,
    NotePriority? priority,
    DateTime? noteDate,
    List<String>? tags,
    List<String>? attachmentUrls,
    bool? isPinned,
    DateTime? reminderDate,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return NoteModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      noteDate: noteDate ?? this.noteDate,
      tags: tags ?? this.tags,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      isPinned: isPinned ?? this.isPinned,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}