import 'package:json_annotation/json_annotation.dart';
import 'package:cargo_mobile/models/branch/branch.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? dateOfBirth;
  final String personalCode;
  final String role;
  final Branch branch;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.dateOfBirth,
    required this.personalCode,
    required this.role,
    required this.branch,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
