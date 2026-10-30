import 'package:pos/core/utils/app_date_time_utils.dart';
import '../../domain/entities/subscription_entity.dart';
import 'subscription_creator_model.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.planName,
    required super.amount,
    required super.currency,
    super.paymentDate,
    super.startDate,
    super.endDate,
    super.paymentMethod,
    super.paymentReference,
    required super.status,
    super.notes,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
    super.daysRemaining = 0,
    super.isExpired = false,
    super.creator,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse(rawId?.toString() ?? '0') ?? 0);

    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : (double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0);

    final rawDaysRemaining = json['days_remaining'];
    final daysRemaining = rawDaysRemaining is int
        ? rawDaysRemaining
        : (int.tryParse(rawDaysRemaining?.toString() ?? '0') ?? 0);

    final rawIsExpired = json['is_expired'];
    final isExpired = rawIsExpired is bool
        ? rawIsExpired
        : (rawIsExpired?.toString().toLowerCase() == 'true');

    final rawCreatedBy = json['created_by'];
    final createdBy = rawCreatedBy is int
        ? rawCreatedBy
        : (int.tryParse(rawCreatedBy?.toString() ?? ''));

    SubscriptionCreatorModel? creator;
    if (json['creator'] is Map<String, dynamic>) {
      creator = SubscriptionCreatorModel.fromJson(json['creator'] as Map<String, dynamic>);
    }

    return SubscriptionModel(
      id: id,
      planName: json['plan_name']?.toString() ?? '',
      amount: amount,
      currency: json['currency']?.toString() ?? 'LKR',
      paymentDate: AppDateTimeUtils.parseServerUtc(json['payment_date']),
      startDate: AppDateTimeUtils.parseServerUtc(json['start_date']),
      endDate: AppDateTimeUtils.parseServerUtc(json['end_date']),
      paymentMethod: json['payment_method']?.toString(),
      paymentReference: json['payment_reference']?.toString(),
      status: json['status']?.toString() ?? 'unknown',
      notes: json['notes']?.toString(),
      createdBy: createdBy,
      createdAt: AppDateTimeUtils.parseServerUtc(json['created_at']),
      updatedAt: AppDateTimeUtils.parseServerUtc(json['updated_at']),
      daysRemaining: daysRemaining,
      isExpired: isExpired,
      creator: creator,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_name': planName,
        'amount': amount.toStringAsFixed(2),
        'currency': currency,
        'payment_date': paymentDate?.toIso8601String(),
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'payment_method': paymentMethod,
        'payment_reference': paymentReference,
        'status': status,
        'notes': notes,
        'created_by': createdBy,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'days_remaining': daysRemaining,
        'is_expired': isExpired,
        if (creator != null && creator is SubscriptionCreatorModel)
          'creator': (creator as SubscriptionCreatorModel).toJson(),
      };
}
