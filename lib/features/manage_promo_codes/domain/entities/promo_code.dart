class PromoCode {
  final int? id;
  final String code;
  final String referral;
  final double salesPercentage;
  final double rentalPercentage;
  final DateTime expireDate;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const PromoCode({
    this.id,
    required this.code,
    required this.referral,
    required this.salesPercentage,
    required this.rentalPercentage,
    required this.expireDate,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  PromoCode copyWith({
    int? id,
    String? code,
    String? referral,
    double? salesPercentage,
    double? rentalPercentage,
    DateTime? expireDate,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PromoCode(
      id: id ?? this.id,
      code: code ?? this.code,
      referral: referral ?? this.referral,
      salesPercentage: salesPercentage ?? this.salesPercentage,
      rentalPercentage: rentalPercentage ?? this.rentalPercentage,
      expireDate: expireDate ?? this.expireDate,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
