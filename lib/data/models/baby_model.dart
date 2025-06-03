import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }

class BabyModel {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final Gender gender;
  final double? birthWeight; // in kg
  final double? birthHeight; // in cm
  final String? photoUrl;
  final String? bloodType;
  final List<String> parentIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  BabyModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.birthWeight,
    this.birthHeight,
    this.photoUrl,
    this.bloodType,
    required this.parentIds,
    required this.createdAt,
    required this.updatedAt,
  });

  int get ageInDays => DateTime.now().difference(dateOfBirth).inDays;
  
  // Compatibility getter for birthDate
  DateTime get birthDate => dateOfBirth;
  
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
    if (now.day < dateOfBirth.day) months--;
    return months;
  }

  String get ageString {
    final months = ageInMonths;
    if (months < 1) {
      return '$ageInDays days';
    } else if (months < 12) {
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths == 0) {
        return '$years ${years == 1 ? 'year' : 'years'}';
      }
      return '$years ${years == 1 ? 'year' : 'years'}, $remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
    }
  }

  factory BabyModel.fromMap(Map<String, dynamic> map, String id) {
    return BabyModel(
      id: id,
      name: map['name'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      gender: Gender.values.firstWhere(
        (g) => g.toString().split('.').last == map['gender'],
        orElse: () => Gender.other,
      ),
      birthWeight: map['birthWeight']?.toDouble(),
      birthHeight: map['birthHeight']?.toDouble(),
      photoUrl: map['photoUrl'],
      bloodType: map['bloodType'],
      parentIds: List<String>.from(map['parentIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create from JSON for repository compatibility
  factory BabyModel.fromJson(Map<String, dynamic> json) {
    return BabyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : DateTime.now(),
      gender: json['gender'] != null
          ? Gender.values.firstWhere(
              (g) => g.toString().split('.').last == json['gender'],
              orElse: () => Gender.other,
            )
          : Gender.other,
      birthWeight: json['birthWeight']?.toDouble(),
      birthHeight: json['birthHeight']?.toDouble(),
      photoUrl: json['photoUrl'],
      bloodType: json['bloodType'],
      parentIds: json['parentIds'] != null 
          ? List<String>.from(json['parentIds']) 
          : [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender.toString().split('.').last,
      'birthWeight': birthWeight,
      'birthHeight': birthHeight,
      'photoUrl': photoUrl,
      'bloodType': bloodType,
      'parentIds': parentIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BabyModel copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    double? birthWeight,
    double? birthHeight,
    String? photoUrl,
    String? bloodType,
    List<String>? parentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BabyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      birthWeight: birthWeight ?? this.birthWeight,
      birthHeight: birthHeight ?? this.birthHeight,
      photoUrl: photoUrl ?? this.photoUrl,
      bloodType: bloodType ?? this.bloodType,
      parentIds: parentIds ?? this.parentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}