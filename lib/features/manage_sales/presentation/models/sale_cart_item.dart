import 'package:pos/features/manage_sale_items/domain/entities/sale_item.dart';

/// Lightweight cart product snapshot — decoupled from [SaleItem] domain
/// validation rules (no category/brand requirements).
class SaleCartProduct {
  final int id;
  final String name;
  final int stockQuantity;
  final double sellingPrice;

  SaleCartProduct({
    required this.id,
    required this.name,
    required this.stockQuantity,
    required this.sellingPrice,
  });

  factory SaleCartProduct.fromSaleItem(SaleItem item) {
    return SaleCartProduct(
      id: item.id,
      name: item.name,
      stockQuantity: item.stockQuantity,
      sellingPrice: item.sellingPrice,
    );
  }
}

/// Represents one line item in the sale creation/editing cart.
class SaleCreateItemEntry {
  final SaleCartProduct product;
  int quantity;
  double pricePerUnit;

  SaleCreateItemEntry({
    required this.product,
    required this.quantity,
    required this.pricePerUnit,
  });

  double get lineTotal => quantity * pricePerUnit;
}