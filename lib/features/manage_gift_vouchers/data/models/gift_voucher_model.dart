import 'package:pos/core/utils/app_date_time_utils.dart';
import '../../domain/entities/gift_voucher.dart';

class GiftVoucherModel extends GiftVoucher {
  const GiftVoucherModel({
    super.id,
    required super.code,
    required super.owner,
    required super.initialAmount,
    required super.balance,
    required super.expireDate,
    super.description,
    super.currency = 'LKR',
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  factory GiftVoucherModel.fromJson(Map<String, dynamic> json) {
    return GiftVoucherModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      code: json['code']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      initialAmount: (json['initial_amount'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      expireDate: AppDateTimeUtils.toLocal(json['expire_date']) ?? DateTime.now(),
      description: json['description']?.toString(),
      currency: json['currency']?.toString() ?? 'LKR',
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
      createdAt: AppDateTimeUtils.toLocal(json['created_at']),
      updatedAt: AppDateTimeUtils.toLocal(json['updated_at']),
    );
  }

  factory GiftVoucherModel.fromEntity(GiftVoucher entity) {
    return GiftVoucherModel(
      id: entity.id,
      code: entity.code,
      owner: entity.owner,
      initialAmount: entity.initialAmount,
      balance: entity.balance,
      expireDate: entity.expireDate,
      description: entity.description,
      currency: entity.currency,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'code': code,
      'owner': owner,
      'initial_amount': initialAmount,
      'balance': balance,
      'expire_date': AppDateTimeUtils.toUtcDateOnly(expireDate) ?? expireDate.toIso8601String().split('T').first,
      'currency': currency,
      'is_active': isActive,
    };
    if (description != null && description!.isNotEmpty) {
      map['description'] = description;
    }
    return map;
  }
}
