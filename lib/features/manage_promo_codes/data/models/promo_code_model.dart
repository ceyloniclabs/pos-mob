import 'package:pos/core/utils/app_date_time_utils.dart';
import '../../domain/entities/promo_code.dart';

class PromoCodeModel extends PromoCode {
  const PromoCodeModel({
    super.id,
    required super.code,
    required super.referral,
    required super.salesPercentage,
    required super.rentalPercentage,
    required super.expireDate,
    super.description,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) {
    return PromoCodeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      code: json['code']?.toString() ?? '',
      referral: json['referral']?.toString() ?? '',
      salesPercentage: (json['sales_percentage'] as num?)?.toDouble() ?? 0.0,
      rentalPercentage: (json['rental_percentage'] as num?)?.toDouble() ?? 0.0,
      expireDate: AppDateTimeUtils.toLocal(json['expire_date']) ?? DateTime.now(),
      description: json['description']?.toString(),
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
      createdAt: AppDateTimeUtils.toLocal(json['created_at']),
      updatedAt: AppDateTimeUtils.toLocal(json['updated_at']),
      deletedAt: AppDateTimeUtils.toLocal(json['deleted_at']),
    );
  }

  factory PromoCodeModel.fromEntity(PromoCode entity) {
    return PromoCodeModel(
      id: entity.id,
      code: entity.code,
      referral: entity.referral,
      salesPercentage: entity.salesPercentage,
      rentalPercentage: entity.rentalPercentage,
      expireDate: entity.expireDate,
      description: entity.description,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'code': code,
      'referral': referral,
      'sales_percentage': salesPercentage,
      'rental_percentage': rentalPercentage,
      'expire_date': AppDateTimeUtils.toUtcDateOnly(expireDate) ?? expireDate.toIso8601String().split('T').first,
      'is_active': isActive,
    };
    if (description != null && description!.isNotEmpty) {
      map['description'] = description;
    }
    return map;
  }
}
