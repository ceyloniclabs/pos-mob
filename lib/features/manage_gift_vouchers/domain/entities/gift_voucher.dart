class GiftVoucher {
  final int? id;
  final String code;
  final String owner;
  final double initialAmount;
  final double balance;
  final DateTime expireDate;
  final String? description;
  final String currency;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GiftVoucher({
    this.id,
    required this.code,
    required this.owner,
    required this.initialAmount,
    required this.balance,
    required this.expireDate,
    this.description,
    this.currency = 'LKR',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  GiftVoucher copyWith({
    int? id,
    String? code,
    String? owner,
    double? initialAmount,
    double? balance,
    DateTime? expireDate,
    String? description,
    String? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GiftVoucher(
      id: id ?? this.id,
      code: code ?? this.code,
      owner: owner ?? this.owner,
      initialAmount: initialAmount ?? this.initialAmount,
      balance: balance ?? this.balance,
      expireDate: expireDate ?? this.expireDate,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
