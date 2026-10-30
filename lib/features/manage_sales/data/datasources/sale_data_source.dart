import 'package:pos/features/manage_customers/data/models/customer_model.dart';
import 'package:pos/features/manage_sale_items/data/models/sale_item_inventory_model.dart';
import '../models/sale_model.dart';

abstract class SaleDataSource {
  Future<List<SaleModel>> getSales(int page, {Map<String, dynamic>? filters});
  Future<SaleModel> getSaleById(int id);
  Future<List<SaleItemInventoryModel>> getSaleItems({Map<String, dynamic>? filters});
  Future<List<CustomerModel>> getCustomers({Map<String, dynamic>? filters});
  Future<String> createSale(SaleModel sale);
  Future<String> updateSale(int id, SaleModel sale);
  Future<String> updateCardReference(int id, String transactionId, {String status = 'completed'});
  Future<String> getSaleInvoiceUrl(int id);
  Future<void> deleteSale(int id);
}
