import 'package:pos/features/manage_gift_vouchers/data/models/gift_voucher_model.dart';
import 'package:pos/features/manage_gift_vouchers/domain/entities/gift_voucher.dart';
import 'package:pos/features/manage_promo_codes/data/models/promo_code_model.dart';
import 'package:pos/features/manage_promo_codes/domain/entities/promo_code.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';

class SaleModel extends Sale {
  SaleModel({
    required super.id,
    super.customerId,
    super.staffId,
    required super.saleDate,
    required super.totalAmount,
    required super.discountAmount,
    super.promoCode,
    super.promoCodeId,
    super.promoCodeDiscount,
    super.giftVoucherId,
    super.giftVoucherAmount,
    required super.paymentMethod,
    super.transactionId,
    super.notes,
    required super.saleStatus,
    super.amountPaid,
    super.changeAmount,
    super.customer,
    super.staff,
    required super.saleItemEntries,
    super.giftVoucher,
    super.promoCodeDetails,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final entriesRaw = json['saleItemEntries'] ?? json['sale_item_entries'];

    SaleCustomer? customerObj;
    if (json['customer'] != null && json['customer'] is Map) {
      final cMap = Map<String, dynamic>.from(json['customer']);
      customerObj = SaleCustomer(
        id: int.tryParse(cMap['id']?.toString() ?? '0') ?? 0,
        name: cMap['name']?.toString() ?? '',
        phone: cMap['phone']?.toString(),
        email: cMap['email']?.toString(),
      );
    }

    SaleStaff? staffObj;
    if (json['staff'] != null && json['staff'] is Map) {
      final sMap = Map<String, dynamic>.from(json['staff']);
      staffObj = SaleStaff(
        id: int.tryParse(sMap['id']?.toString() ?? '0') ?? 0,
        name: sMap['name']?.toString() ?? '',
        email: sMap['email']?.toString(),
        role: sMap['role']?.toString(),
      );
    }

    GiftVoucher? voucherObj;
    if (json['gift_voucher'] != null && json['gift_voucher'] is Map) {
      try {
        voucherObj = GiftVoucherModel.fromJson(
          Map<String, dynamic>.from(json['gift_voucher']),
        );
      } catch (_) {}
    }

    PromoCode? promoDetailsObj;
    if (json['promo_code_details'] != null && json['promo_code_details'] is Map) {
      try {
        promoDetailsObj = PromoCodeModel.fromJson(
          Map<String, dynamic>.from(json['promo_code_details']),
        );
      } catch (_) {}
    }

    List<SaleItemEntryModel> entries = [];
    if (entriesRaw != null && entriesRaw is List) {
      entries = entriesRaw
          .map((e) => SaleItemEntryModel.fromJson(
               Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    double? amountPaid = json['amount_paid'] != null
        ? double.tryParse(json['amount_paid'].toString())
        : null;
    double? changeAmount = json['change_amount'] != null
        ? double.tryParse(json['change_amount'].toString())
        : null;

    final txId = json['transaction_id']?.toString();
    if (amountPaid == null && txId != null && txId.contains('CASH_REC:')) {
      final recMatch = RegExp(r'CASH_REC:([0-9.]+)').firstMatch(txId);
      final changeMatch = RegExp(r'CHANGE:([0-9.]+)').firstMatch(txId);
      if (recMatch != null) {
        amountPaid = double.tryParse(recMatch.group(1)!);
      }
      if (changeMatch != null) {
        changeAmount = double.tryParse(changeMatch.group(1)!);
      }
    }

    return SaleModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      customerId: json['customer_id'] != null
          ? int.tryParse(json['customer_id'].toString())
          : null,
      staffId: json['staff_id'] != null
          ? int.tryParse(json['staff_id'].toString())
          : null,
      saleDate: json['sale_date']?.toString() ?? '',
      totalAmount: json['total_amount'] != null
          ? (double.tryParse(json['total_amount'].toString()) ?? 0.0)
          : 0.0,
      discountAmount: json['discount_amount'] != null
          ? (double.tryParse(json['discount_amount'].toString()) ?? 0.0)
          : 0.0,
      promoCode: json['promo_code']?.toString(),
      promoCodeId: json['promo_code_id'] != null
          ? int.tryParse(json['promo_code_id'].toString())
          : null,
      promoCodeDiscount: json['promo_code_discount'] != null
          ? (double.tryParse(json['promo_code_discount'].toString()) ?? 0.0)
          : 0.0,
      giftVoucherId: json['gift_voucher_id'] != null
          ? int.tryParse(json['gift_voucher_id'].toString())
          : null,
      giftVoucherAmount: json['gift_voucher_amount'] != null
          ? (double.tryParse(json['gift_voucher_amount'].toString()) ?? 0.0)
          : 0.0,
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      transactionId: json['transaction_id']?.toString(),
      notes: json['notes']?.toString(),
      saleStatus: json['sale_status']?.toString() ?? 'pending',
      amountPaid: amountPaid,
      changeAmount: changeAmount,
      customer: customerObj,
      staff: staffObj,
      saleItemEntries: entries,
      giftVoucher: voucherObj,
      promoCodeDetails: promoDetailsObj,
    );
  }

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      customerId: sale.customerId,
      staffId: sale.staffId,
      saleDate: sale.saleDate,
      totalAmount: sale.totalAmount,
      discountAmount: sale.discountAmount,
      promoCode: sale.promoCode,
      promoCodeId: sale.promoCodeId,
      promoCodeDiscount: sale.promoCodeDiscount,
      giftVoucherId: sale.giftVoucherId,
      giftVoucherAmount: sale.giftVoucherAmount,
      paymentMethod: sale.paymentMethod,
      transactionId: sale.transactionId,
      notes: sale.notes,
      saleStatus: sale.saleStatus,
      amountPaid: sale.amountPaid,
      changeAmount: sale.changeAmount,
      customer: sale.customer,
      staff: sale.staff,
      saleItemEntries: sale.saleItemEntries,
      giftVoucher: sale.giftVoucher,
      promoCodeDetails: sale.promoCodeDetails,
    );
  }

  /// Serialises this model to the API payload expected by the Laravel backend.
  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'staff_id': staffId,
      'sale_date': saleDate,
      'sale_status': saleStatus,
      'payment_method': paymentMethod,
      'notes': notes ?? '',
      'total_amount': totalAmount,
      'discount_amount': discountAmount.toStringAsFixed(2),
      'promo_code': promoCode ?? '',
      'promo_code_id': promoCodeId,
      'promo_code_discount': promoCodeDiscount,
      'gift_voucher_id': giftVoucherId,
      'gift_voucher_amount': giftVoucherAmount,
      if (amountPaid != null)
        'amount_paid': amountPaid! % 1 == 0 ? amountPaid!.toInt() : amountPaid
      else if (paymentMethod == 'cash')
        'amount_paid': totalAmount % 1 == 0 ? totalAmount.toInt() : totalAmount,
      if (changeAmount != null)
        'change_amount': changeAmount! % 1 == 0 ? changeAmount!.toInt() : changeAmount
      else if (paymentMethod == 'cash')
        'change_amount': 0,
      if (transactionId != null && !transactionId!.startsWith('CASH_REC:'))
        'transaction_id': transactionId,
      'items': saleItemEntries
          .map((e) => {
                'sale_item_id': e.saleItemId,
                'quantity': e.quantity,
                'price_per_unit': e.pricePerUnit.toStringAsFixed(2),
              })
          .toList(),
    };
  }

  Sale toEntity() => this;
}

class SaleItemEntryModel extends SaleItemEntry {
  SaleItemEntryModel({
    required super.id,
    required super.saleId,
    required super.saleItemId,
    required super.quantity,
    required super.pricePerUnit,
    required super.lineTotal,
    super.saleItem,
  });

  factory SaleItemEntryModel.fromJson(Map<String, dynamic> json) {
    final rawItem = json['saleItem'] ?? json['sale_item'];

    SaleItemModel? itemObj;
    if (rawItem != null && rawItem is Map) {
      itemObj = SaleItemModel.fromJson(Map<String, dynamic>.from(rawItem));
    }

    return SaleItemEntryModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      saleId: int.tryParse(json['sale_id']?.toString() ?? '0') ?? 0,
      saleItemId: int.tryParse(json['sale_item_id']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      pricePerUnit: json['price_per_unit'] != null
          ? (double.tryParse(json['price_per_unit'].toString()) ?? 0.0)
          : 0.0,
      lineTotal: json['line_total'] != null
          ? (double.tryParse(json['line_total'].toString()) ?? 0.0)
          : 0.0,
      saleItem: itemObj,
    );
  }

  SaleItemEntry toEntity() => this;
}

class SaleItemModel extends SaleItemSummary {
  SaleItemModel({
    required super.id,
    required super.name,
    required super.sellingPrice,
    required super.stockQuantity,
    super.brandName,
    super.categoryName,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      sellingPrice: json['selling_price']?.toString() ?? '0.00',
      stockQuantity: int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0,
      brandName: json['brand_name']?.toString(),
      categoryName: json['category_name']?.toString(),
    );
  }

  SaleItemSummary toEntity() => this;
}
