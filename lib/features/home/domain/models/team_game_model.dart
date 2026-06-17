import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';

class TeamGameModel {
  const TeamGameModel({
    required this.id,
    required this.teamId,
    required this.name,
    required this.explanation,
    required this.tools,
    required this.laws,
    required this.tags,
    required this.goalTags,
    required this.coverUrl,
    required this.isVisible,
    required this.isPublic,
    required this.createdBy,
    required this.createdAt,
    this.teamName = '',
    this.updatedAt,
  });

  final String id;
  final String teamId;
  final String name;
  final String explanation;
  final String tools;
  final String laws;
  final List<String> tags;
  final List<String> goalTags;
  final String coverUrl;
  final bool isVisible;
  final bool isPublic;
  final String createdBy;
  final DateTime createdAt;
  final String teamName;
  final DateTime? updatedAt;

  String get goalTag => goalTags.join(' - ');

  GameModel toGameModel() {
    return GameModel(
      id: 'team_$id',
      coverUrl: coverUrl,
      name: name,
      explanation: explanation,
      isVisible: isVisible,
      laws: laws,
      tags: tags,
      target: '',
      goalTag: goalTags,
      tools: tools,
      videoLink: '',
      createdAt: createdAt,
      isTeamGame: true,
      teamId: teamId,
      teamName: teamName,
    );
  }

  TeamGameModel copyWith({
    String? id,
    String? teamId,
    String? name,
    String? explanation,
    String? tools,
    String? laws,
    List<String>? tags,
    List<String>? goalTags,
    String? coverUrl,
    bool? isVisible,
    bool? isPublic,
    String? createdBy,
    DateTime? createdAt,
    String? teamName,
    DateTime? updatedAt,
  }) {
    return TeamGameModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      explanation: explanation ?? this.explanation,
      tools: tools ?? this.tools,
      laws: laws ?? this.laws,
      tags: tags ?? this.tags,
      goalTags: goalTags ?? this.goalTags,
      coverUrl: coverUrl ?? this.coverUrl,
      isVisible: isVisible ?? this.isVisible,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      teamName: teamName ?? this.teamName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TeamGameModel.fromJson(Map<String, dynamic> json) {
    return TeamGameModel(
      id: json['id']?.toString() ?? '',
      teamId: json['teamId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      tools: json['tools']?.toString() ?? '',
      laws: json['laws']?.toString() ?? '',
      tags: _stringListFromJson(json['tags']),
      goalTags: _stringListFromJson(json['goalTag'] ?? json['goalTags']),
      coverUrl: json['coverUrl']?.toString() ?? '',
      isVisible: _boolFromJson(json['isVisible'], defaultValue: true),
      isPublic: _boolFromJson(json['isPublic'], defaultValue: false),
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      teamName: json['teamName']?.toString() ?? '',
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'name': name,
      'explanation': explanation,
      'tools': tools,
      'laws': laws,
      'tags': tags,
      'goalTag': goalTags,
      'coverUrl': coverUrl,
      'isVisible': isVisible,
      'isPublic': isPublic,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'teamName': teamName,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'name': name,
      'explanation': explanation,
      'tools': tools,
      'laws': laws,
      'tags': tags,
      'goalTag': goalTags,
      'coverUrl': coverUrl,
      'isVisible': isVisible,
      'isPublic': isPublic,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'teamName': teamName,
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  static List<String> _stringListFromJson(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      return value
          .split(RegExp(r'[,،\n]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final item = value.toString().trim();
    return item.isEmpty ? [] : [item];
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static bool _boolFromJson(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return defaultValue;
  }
}
