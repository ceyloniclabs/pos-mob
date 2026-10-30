import 'subscription_entity.dart';

class CurrentSubscriptionDataEntity {
  final SubscriptionEntity? subscription;
  final bool isExpired;
  final int daysRemaining;
  final DateTime? systemExpiresAt;

  const CurrentSubscriptionDataEntity({
    this.subscription,
    this.isExpired = false,
    this.daysRemaining = 0,
    this.systemExpiresAt,
  });

  bool get hasActiveSubscription =>
      subscription != null && !isExpired && (subscription?.isActive ?? false);

  CurrentSubscriptionDataEntity copyWith({
    SubscriptionEntity? subscription,
    bool? isExpired,
    int? daysRemaining,
    DateTime? systemExpiresAt,
  }) {
    return CurrentSubscriptionDataEntity(
      subscription: subscription ?? this.subscription,
      isExpired: isExpired ?? this.isExpired,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      systemExpiresAt: systemExpiresAt ?? this.systemExpiresAt,
    );
  }
}
