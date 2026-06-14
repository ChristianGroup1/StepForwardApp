import 'package:cloud_firestore/cloud_firestore.dart';

class TeamWorkspaceModel {
  const TeamWorkspaceModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.ownerId,
    required this.members,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String inviteCode;
  final String ownerId;
  final List<String> members;
  final DateTime createdAt;

  int get memberCount => members.length;

  factory TeamWorkspaceModel.fromJson(Map<String, dynamic> json) {
    return TeamWorkspaceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      inviteCode: json['inviteCode'] ?? '',
      ownerId: json['ownerId'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'ownerId': ownerId,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'ownerId': ownerId,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TeamWorkspaceModel copyWith({
    String? id,
    String? name,
    String? inviteCode,
    String? ownerId,
    List<String>? members,
    DateTime? createdAt,
  }) {
    return TeamWorkspaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
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
