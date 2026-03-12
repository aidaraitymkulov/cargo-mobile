// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phone: json['phone'] as String,
  dateOfBirth: json['dateOfBirth'] as String?,
  personalCode: json['personalCode'] as String,
  role: json['role'] as String,
  branch: Branch.fromJson(json['branch'] as Map<String, dynamic>),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phone': instance.phone,
  'dateOfBirth': instance.dateOfBirth,
  'personalCode': instance.personalCode,
  'role': instance.role,
  'branch': instance.branch,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
