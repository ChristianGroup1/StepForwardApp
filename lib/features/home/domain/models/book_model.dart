class BookModel {
  final String name;
  final String url;
  final String id;
  final String? coverUrl;
  BookModel({
    required this.name,
    required this.url,
    required this.id,
    this.coverUrl,
  });
  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
    name: json['name'] ?? '',
    url: json['url'] ?? '',
    id: json['id'] ?? '',
    coverUrl: json['coverUrl'] ?? '',
  );
}
