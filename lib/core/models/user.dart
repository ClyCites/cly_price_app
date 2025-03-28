class User {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? profilePicture;

  User({
    this.id,
    this.name,
    this.email,
    this.role,
    this.profilePicture, // Added to constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user',
      profilePicture: json['profilePicture'], // Parse from JSON
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'] ?? 'user',
      profilePicture: map['profilePicture'], // Parse from map
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profilePicture': profilePicture,
    };
  }
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, profilePicture: $profilePicture)';
  }
}

