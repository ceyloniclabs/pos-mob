class SubscriptionCreatorEntity {
  final int id;
  final String name;
  final String email;

  const SubscriptionCreatorEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  SubscriptionCreatorEntity copyWith({
    int? id,
    String? name,
    String? email,
  }) {
    return SubscriptionCreatorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
