class UserModel {
  final String id;
  final String name;
  final String employeeCode;
  final String? officeRoom;
  final String? department;

  UserModel({
    required this.id,
    required this.name,
    required this.employeeCode,
    this.officeRoom,
    this.department,
  });

  /// Factory constructor to create a User from API JSON or Local Storage Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      officeRoom: json['office_room'],
      department: json['department'],
    );
  }

  /// Convert User model to Map for Hive/Local Storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employee_code': employeeCode,
      'office_room': officeRoom,
      'department': department,
    };
  }

  /// Create a copy of the user with modified fields
  UserModel copyWith({
    String? id,
    String? name,
    String? employeeCode,
    String? officeRoom,
    String? department,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeCode: employeeCode ?? this.employeeCode,
      officeRoom: officeRoom ?? this.officeRoom,
      department: department ?? this.department,
    );
  }
}
