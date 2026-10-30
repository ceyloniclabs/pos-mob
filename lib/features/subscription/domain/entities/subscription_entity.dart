import 'subscription_creator_entity.dart';

class SubscriptionEntity {
  final int id;
  final String planName;
  final double amount;
  final String currency;
  final DateTime? paymentDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentMethod;
  final String? paymentReference;
  final String status;
  final String? notes;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int daysRemaining;
  final bool isExpired;
  final SubscriptionCreatorEntity? creator;

  const SubscriptionEntity({
    required this.id,
    required this.planName,
    required this.amount,
    required this.currency,
    this.paymentDate,
    this.startDate,
    this.endDate,
    this.paymentMethod,
    this.paymentReference,
    required this.status,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.daysRemaining = 0,
    this.isExpired = false,
    this.creator,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isStatusExpired => isExpired || status.toLowerCase() == 'expired';

  SubscriptionEntity copyWith({
    int? id,
    String? planName,
    double? amount,
    String? currency,
    DateTime? paymentDate,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethod,
    String? paymentReference,
    String? status,
    String? notes,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? daysRemaining,
    bool? isExpired,
    SubscriptionCreatorEntity? creator,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentDate: paymentDate ?? this.paymentDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      isExpired: isExpired ?? this.isExpired,
      creator: creator ?? this.creator,
    );
  }
}
