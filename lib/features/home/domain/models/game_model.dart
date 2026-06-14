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
      isVisible: json['isVisible'] ?? false,
      laws: json['laws'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      target: json['target'] ?? '',
      goalTag: json['goalTag'] ?? '',
      tools: json['tools'] ?? '',
      videoLink: json['videoLink'] ?? '',
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
      'createdAt': createdAt?.toIso8601String(),
    };
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
}
