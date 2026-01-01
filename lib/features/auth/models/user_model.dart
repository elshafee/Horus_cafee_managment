class UserModel {
  final String name;
  final String employeeCode;
  final String? department; // New
  final String? primaryRoom; // New
  final String? profileImage; // New (URL or Base64)

  UserModel({
    required this.name,
    required this.employeeCode,
    this.department,
    this.primaryRoom,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['staff_name'] ?? '',
      employeeCode: json['staff_id'] ?? '',
      department: json['department'],
      primaryRoom: json['room'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_name': name,
      'staff_id': employeeCode,
      'department': department,
      'room': primaryRoom,
      'profile_image': profileImage,
    };
  }
}
