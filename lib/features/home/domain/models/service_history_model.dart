import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceHistoryModel {
  ServiceHistoryModel({
    required this.id,
    required this.title,
    required this.place,
    required this.date,
    required this.games,
    required this.ageGroup,
    required this.notes,
    required this.createdAt,
    String? syncId,
  }) : syncId = syncId == null || syncId.isEmpty ? id : syncId;

  final String id;
  final String title;
  final String place;
  final DateTime date;
  final List<String> games;
  final String ageGroup;
  final String notes;
  final DateTime createdAt;
  final String syncId;

  factory ServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      place: json['place'] ?? '',
      date: _dateFromJson(json['date']) ?? DateTime.now(),
      games: List<String>.from(json['games'] ?? []),
      ageGroup: json['ageGroup'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      syncId: json['syncId'] ?? json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'place': place,
      'date': date.toIso8601String(),
      'games': games,
      'ageGroup': ageGroup,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'syncId': syncId,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'place': place,
      'date': Timestamp.fromDate(date),
      'games': games,
      'ageGroup': ageGroup,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'syncId': syncId,
    };
  }

  ServiceHistoryModel copyWith({
    String? id,
    String? title,
    String? place,
    DateTime? date,
    List<String>? games,
    String? ageGroup,
    String? notes,
    DateTime? createdAt,
    String? syncId,
  }) {
    return ServiceHistoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      place: place ?? this.place,
      date: date ?? this.date,
      games: games ?? this.games,
      ageGroup: ageGroup ?? this.ageGroup,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      syncId: syncId ?? this.syncId,
    );
  }

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final searchableText = [
      title,
      place,
      ageGroup,
      notes,
      ...games,
    ].join(' ').toLowerCase();

    return searchableText.contains(normalizedQuery);
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
