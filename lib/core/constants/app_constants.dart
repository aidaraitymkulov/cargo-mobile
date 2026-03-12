import 'package:json_annotation/json_annotation.dart';

abstract class AppConstants {
  static const String baseUrl = 'https://api.cargo-app.com';
  static const String wsUrl = 'wss://api.cargo-app.com/ws/chat';

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
  @JsonValue(0) active,
  @JsonValue(1) inactive,
  @JsonValue(2) deleted,
  @JsonValue(3) pendingDeletion,
}
