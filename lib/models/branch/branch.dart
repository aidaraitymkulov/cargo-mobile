import 'package:json_annotation/json_annotation.dart';
part 'branch.g.dart';

@JsonSerializable()
class Branch {
  final String id;
  final String address;
  final String personalCodePrefix;
  final bool isActive;

  const Branch({
    required this.id,
    required this.address,
    required this.personalCodePrefix,
    required this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);
  Map<String, dynamic> toJson() => _$BranchToJson(this);
}
