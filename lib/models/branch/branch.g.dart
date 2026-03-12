// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Branch _$BranchFromJson(Map<String, dynamic> json) => Branch(
  id: json['id'] as String,
  address: json['address'] as String,
  personalCodePrefix: json['personalCodePrefix'] as String,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$BranchToJson(Branch instance) => <String, dynamic>{
  'id': instance.id,
  'address': instance.address,
  'personalCodePrefix': instance.personalCodePrefix,
  'isActive': instance.isActive,
};
