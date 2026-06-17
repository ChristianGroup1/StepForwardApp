class GameModel {
  final String coverUrl;
  final String id;
  final String name;
  final String explanation;
  final bool isVisible;
  final String laws;
  final List<String> tags;
  final String target;
  final List<String> goalTags;
  final String tools;
  final String videoLink;
  final DateTime? createdAt;
  final double ratingAverage;
  final int ratingCount;
  final bool isTeamGame;
  final String teamId;
  final String teamName;

  GameModel({
    required this.coverUrl,
    required this.name,
    required this.id,
    required this.explanation,
    required this.isVisible,
    required this.laws,
    required this.tags,
    required this.target,
    required this.tools,
    required this.videoLink,
    this.createdAt,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.isTeamGame = false,
    this.teamId = '',
    this.teamName = '',
    Object? goalTag = '',
  }) : goalTags = _goalTagsFromJson(goalTag);

  String get goalTag => goalTags.join(' - ');

  List<String> get filterTargets =>
      goalTags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();

  String get filterTarget => filterTargets.join(' ');

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      coverUrl: json['coverUrl'] ?? '',
      name: json['name'] ?? '',
      explanation: json['explanation'] ?? '',
      id: json['id'] ?? '',
      isVisible: _boolFromJson(json['isVisible'], defaultValue: true),
      laws: json['laws'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      target: json['target'] ?? '',
      goalTag: json['goalTag'] ?? '',
      tools: json['tools'] ?? '',
      videoLink: json['videoLink'] ?? '',
      ratingAverage: _doubleFromJson(json['ratingAverage']),
      ratingCount: _intFromJson(json['ratingCount']),
      isTeamGame: _boolFromJson(json['isTeamGame'], defaultValue: false),
      teamId: json['teamId']?.toString() ?? '',
      teamName: json['teamName']?.toString() ?? '',
      createdAt: _dateFromJson(
        json['createdAt'] ?? json['created_at'] ?? json['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coverUrl': coverUrl,
      'id': id,
      'name': name,
      'explanation': explanation,
      'isVisible': isVisible,
      'laws': laws,
      'tags': tags,
      'target': target,
      'goalTag': goalTags,
      'tools': tools,
      'videoLink': videoLink,
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
      'isTeamGame': isTeamGame,
      'teamId': teamId,
      'teamName': teamName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get formattedRatingAverage {
    if (ratingCount <= 0 || ratingAverage <= 0) return '0.0';
    return ratingAverage.toStringAsFixed(1);
  }

  static List<String> _goalTagsFromJson(dynamic value) {
    if (value == null) return [];

    if (value is String) {
      final tag = value.trim();
      return tag.isEmpty ? [] : [tag];
    }

    if (value is Iterable) {
      return value
          .map((tag) => tag.toString().trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    final tag = value.toString().trim();
    return tag.isEmpty ? [] : [tag];
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);

    try {
      final dynamic timestamp = value;
      final date = timestamp.toDate();
      if (date is DateTime) return date;
    } catch (_) {}

    return null;
  }

  static int _intFromJson(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _doubleFromJson(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _boolFromJson(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;

    return defaultValue;
  }
}
