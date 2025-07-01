class GameModel {
  final String coverUrl;
  final String id;
  final String name;
  final String explanation;
  final bool isVisible;
  final String laws;
  final List<String> tags;
  final String target;
  final String tools;
  final String videoLink;

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
  });

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
      tools: json['tools'] ?? '',
      videoLink: json['videoLink'] ?? '',
    );
  }
}
