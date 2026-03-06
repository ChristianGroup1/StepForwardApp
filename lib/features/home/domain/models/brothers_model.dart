class BrothersModel {
  final String id;
  final String name;
  final String coverUrl;
  final String phoneNumber;
  final List<String> tags;
  final String churchName;
  final String government;
  final String? city;
  final String? denomination;
  final bool? isVisible;
  final List<String>? preferredMinistries;

  BrothersModel({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.phoneNumber,
    required this.tags,
    this.isVisible,
    this.denomination,
    required this.churchName,
    required this.government,
    this.city,
    this.preferredMinistries,
  });

  factory BrothersModel.fromJson(Map<String, dynamic> json) {
    return BrothersModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isVisible: json['isVisible'] ,
      denomination: json['denomination'],
      tags: List<String>.from(json['tags'] ?? []),
      churchName: json['churchName'] ?? '',
      government: json['government'] ?? '',
      city: json['city'] ?? '',
      preferredMinistries: List<String>.from(json['preferredMinistries'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverUrl': coverUrl,
      'phoneNumber': phoneNumber,
      'tags': tags,
      'denomination': denomination,
      'churchName': churchName,
      'isVisible': isVisible,
      'government': government,
      'city': city,
      'preferredMinistries': preferredMinistries
    };
  }
}