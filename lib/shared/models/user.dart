class User {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;
  final String? profilePhotoUrl;
  final String? token; // Sanctum token

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    this.profilePhotoUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin:
          json['is_admin'] == 1 ||
          json['is_admin'] == true ||
          json['is_admin'] == '1',
      profilePhotoUrl: json['profile_photo_url'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_admin': isAdmin,
      'profile_photo_url': profilePhotoUrl,
      'token': token,
    };
  }
}
