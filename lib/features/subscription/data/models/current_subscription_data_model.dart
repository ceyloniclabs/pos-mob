import 'package:pos/core/utils/app_date_time_utils.dart';
import '../../domain/entities/current_subscription_data_entity.dart';
import 'subscription_model.dart';

class CurrentSubscriptionDataModel extends CurrentSubscriptionDataEntity {
  const CurrentSubscriptionDataModel({
    super.subscription,
    super.isExpired = false,
    super.daysRemaining = 0,
    super.systemExpiresAt,
  });

  factory CurrentSubscriptionDataModel.fromJson(Map<String, dynamic> json) {
    SubscriptionModel? subscription;
    if (json['subscription'] is Map<String, dynamic>) {
      subscription = SubscriptionModel.fromJson(
        json['subscription'] as Map<String, dynamic>,
      );
    }

    final rawIsExpired = json['is_expired'];
    final isExpired = rawIsExpired is bool
        ? rawIsExpired
        : (rawIsExpired?.toString().toLowerCase() == 'true');

    final rawDaysRemaining = json['days_remaining'];
    final daysRemaining = rawDaysRemaining is int
        ? rawDaysRemaining
        : (int.tryParse(rawDaysRemaining?.toString() ?? '0') ?? 0);

    final systemExpiresAt = AppDateTimeUtils.parseServerUtc(json['system_expires_at']);

    return CurrentSubscriptionDataModel(
      subscription: subscription,
      isExpired: isExpired,
      daysRemaining: daysRemaining,
      systemExpiresAt: systemExpiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        if (subscription != null && subscription is SubscriptionModel)
          'subscription': (subscription as SubscriptionModel).toJson(),
        'is_expired': isExpired,
        'days_remaining': daysRemaining,
        'system_expires_at': systemExpiresAt?.toIso8601String(),
      };
}
