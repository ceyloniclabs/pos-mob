import '../../domain/entities/subscription_creator_entity.dart';

class SubscriptionCreatorModel extends SubscriptionCreatorEntity {
  const SubscriptionCreatorModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory SubscriptionCreatorModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse(rawId?.toString() ?? '0') ?? 0);

    return SubscriptionCreatorModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
