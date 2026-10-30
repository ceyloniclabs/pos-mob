import '../../domain/entities/payment_invoice.dart';

class PaymentInvoiceModel {
  final double totalRental;
  final double totalLateFee;
  final double totalDamageFee;
  final double totalCharged;
  final double totalPaid;
  final double totalAdvance;
  final double totalDeposit;
  final double balanceDue;

  PaymentInvoiceModel({
    required this.totalRental,
    required this.totalLateFee,
    required this.totalDamageFee,
    required this.totalCharged,
    required this.totalPaid,
    required this.totalAdvance,
    required this.totalDeposit,
    required this.balanceDue,
  });

  factory PaymentInvoiceModel.fromJson(Map<String, dynamic> json) {
    return PaymentInvoiceModel(
      totalRental: (json['total_rental'] as num?)?.toDouble() ?? 0.0,
      totalLateFee: (json['total_late_fee'] as num?)?.toDouble() ?? 0.0,
      totalDamageFee: (json['total_damage_fee'] as num?)?.toDouble() ?? 0.0,
      totalCharged: (json['total_charged'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      totalAdvance: (json['total_advance'] as num?)?.toDouble() ?? 0.0,
      totalDeposit: (json['total_deposit'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_rental': totalRental,
      'total_late_fee': totalLateFee,
      'total_damage_fee': totalDamageFee,
      'total_charged': totalCharged,
      'total_paid': totalPaid,
      'total_advance': totalAdvance,
      'total_deposit': totalDeposit,
      'balance_due': balanceDue,
    };
  }

  PaymentInvoice toEntity() {
    return PaymentInvoice(
      totalRental: totalRental,
      totalLateFee: totalLateFee,
      totalDamageFee: totalDamageFee,
      totalCharged: totalCharged,
      totalPaid: totalPaid,
      totalAdvance: totalAdvance,
      totalDeposit: totalDeposit,
      balanceDue: balanceDue,
    );
  }

  factory PaymentInvoiceModel.fromEntity(PaymentInvoice entity) {
    return PaymentInvoiceModel(
      totalRental: entity.totalRental,
      totalLateFee: entity.totalLateFee,
      totalDamageFee: entity.totalDamageFee,
      totalCharged: entity.totalCharged,
      totalPaid: entity.totalPaid,
      totalAdvance: entity.totalAdvance,
      totalDeposit: entity.totalDeposit,
      balanceDue: entity.balanceDue,
    );
  }
}
