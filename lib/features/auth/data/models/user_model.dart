class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final bool isApproved;
  final String email;
  final String phoneNumber;
  final String government;
  final String churchName;
  final String? frontId;
  final String? backId;
  final List<String>? favorites;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.isApproved = false,
    required this.email,
    this.favorites,
    required this.phoneNumber,
    required this.government,
    required this.churchName,
     this.frontId,
     this.backId,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      isApproved: json['isApproved'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      government: json['government'],
      churchName: json['churchName'],
      frontId: json['frontId'],
      backId: json['backId'],
      favorites: List<String>.from(json['favorites'] ?? []),
    );
  }
  toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'isApproved': isApproved,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'government': government,
      'churchName': churchName,
      'frontId': frontId,
      'backId': backId,
      'favorites': favorites
    };
  }
}
