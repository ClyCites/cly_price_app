class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profilePicture;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user',
      permissions: List<String>.from(json['permissions'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'permissions': permissions,
      'isActive': isActive,
      
    };
  }
}

