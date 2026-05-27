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

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as String,
        address: json['address'] as String,
        personalCodePrefix: json['personalCodePrefix'] as String,
        isActive: json['isActive'] as bool,
      );

  /// Пример: "AN — ул. Киевская 77"
  String get displayName => '$personalCodePrefix — $address';
}
