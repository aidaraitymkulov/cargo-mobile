import 'package:json_annotation/json_annotation.dart';

abstract class AppConstants {
  static const String baseUrl = String.fromEnvironment('BASE_URL');
  static const String wsUrl = String.fromEnvironment('WS_URL');

  static const int defaultPageSize = 20;
  static const int chatPageSize = 50;
}

enum ProductStatus {
  @JsonValue('IN_CHINA') inChina,
  @JsonValue('ON_THE_WAY') onTheWay,
  @JsonValue('IN_KG') inKg,
  @JsonValue('DELIVERED') delivered,
}

enum OrderStatus {
  @JsonValue('PENDING_PICKUP') pendingPickup,
  @JsonValue('DELIVERED') delivered,
}

enum UserStatus {
  @JsonValue('ACTIVE') active,
  @JsonValue('INACTIVE') inactive,
  @JsonValue('DELETED') deleted,
  @JsonValue('PENDING_DELETION') pendingDeletion,
}
