class UserModel {
  final String id;
  final String email;
  final String role;
  final String enforcementState;
  final bool isAgeVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.enforcementState,
    required this.isAgeVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'USER',
      enforcementState: json['enforcementState'] ?? 'NONE',
      isAgeVerified: json['isAgeVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

