import 'package:pos/features/manage_gift_vouchers/domain/entities/gift_voucher.dart';
import 'package:pos/features/manage_promo_codes/domain/entities/promo_code.dart';

class Sale {
  final int id;
  final int? customerId;
  final int? staffId;
  final String saleDate;
  final double totalAmount;
  final double discountAmount;
  final String? promoCode;
  final int? promoCodeId;
  final double promoCodeDiscount;
  final int? giftVoucherId;
  final double giftVoucherAmount;
  final String paymentMethod;
  final String? transactionId;
  final String? notes;
  final String saleStatus;
  final double? amountPaid;
  final double? changeAmount;
  final SaleCustomer? customer;
  final SaleStaff? staff;
  final List<SaleItemEntry> saleItemEntries;
  final GiftVoucher? giftVoucher;
  final PromoCode? promoCodeDetails;

  Sale({
    required this.id,
    this.customerId,
    this.staffId,
    required this.saleDate,
    required this.totalAmount,
    required this.discountAmount,
    this.promoCode,
    this.promoCodeId,
    this.promoCodeDiscount = 0.0,
    this.giftVoucherId,
    this.giftVoucherAmount = 0.0,
    required this.paymentMethod,
    this.transactionId,
    this.notes,
    required this.saleStatus,
    this.amountPaid,
    this.changeAmount,
    this.customer,
    this.staff,
    required this.saleItemEntries,
    this.giftVoucher,
    this.promoCodeDetails,
  });

  Sale copyWith({
    int? id,
    int? customerId,
    int? staffId,
    String? saleDate,
    double? totalAmount,
    double? discountAmount,
    String? promoCode,
    int? promoCodeId,
    double? promoCodeDiscount,
    int? giftVoucherId,
    double? giftVoucherAmount,
    String? paymentMethod,
    String? transactionId,
    String? notes,
    String? saleStatus,
    double? amountPaid,
    double? changeAmount,
    SaleCustomer? customer,
    SaleStaff? staff,
    List<SaleItemEntry>? saleItemEntries,
    GiftVoucher? giftVoucher,
    PromoCode? promoCodeDetails,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      staffId: staffId ?? this.staffId,
      saleDate: saleDate ?? this.saleDate,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      promoCode: promoCode ?? this.promoCode,
      promoCodeId: promoCodeId ?? this.promoCodeId,
      promoCodeDiscount: promoCodeDiscount ?? this.promoCodeDiscount,
      giftVoucherId: giftVoucherId ?? this.giftVoucherId,
      giftVoucherAmount: giftVoucherAmount ?? this.giftVoucherAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      saleStatus: saleStatus ?? this.saleStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      changeAmount: changeAmount ?? this.changeAmount,
      customer: customer ?? this.customer,
      staff: staff ?? this.staff,
      saleItemEntries: saleItemEntries ?? this.saleItemEntries,
      giftVoucher: giftVoucher ?? this.giftVoucher,
      promoCodeDetails: promoCodeDetails ?? this.promoCodeDetails,
    );
  }
}


class SaleItemEntry {
  final int id;
  final int saleId;
  final int saleItemId;
  final int quantity;
  final double pricePerUnit;
  final double lineTotal;
  final SaleItemSummary? saleItem;

  SaleItemEntry({
    required this.id,
    required this.saleId,
    required this.saleItemId,
    required this.quantity,
    required this.pricePerUnit,
    required this.lineTotal,
    this.saleItem,
  });

  SaleItemEntry copyWith({
    int? id,
    int? saleId,
    int? saleItemId,
    int? quantity,
    double? pricePerUnit,
    double? lineTotal,
    SaleItemSummary? saleItem,
  }) {
    return SaleItemEntry(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      saleItemId: saleItemId ?? this.saleItemId,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      lineTotal: lineTotal ?? this.lineTotal,
      saleItem: saleItem ?? this.saleItem,
    );
  }
}

class SaleItemSummary {
  final int id;
  final String name;
  final String sellingPrice;
  final int stockQuantity;
  final String? brandName;
  final String? categoryName;

  SaleItemSummary({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.stockQuantity,
    this.brandName,
    this.categoryName,
  });

  SaleItemSummary copyWith({
    int? id,
    String? name,
    String? sellingPrice,
    int? stockQuantity,
    String? brandName,
    String? categoryName,
  }) {
    return SaleItemSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

class SaleCustomer {
  final int id;
  final String name;
  final String? phone;
  final String? email;

  SaleCustomer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
  });
}

class SaleStaff {
  final int id;
  final String name;
  final String? email;
  final String? role;

  SaleStaff({
    required this.id,
    required this.name,
    this.email,
    this.role,
  });
}
