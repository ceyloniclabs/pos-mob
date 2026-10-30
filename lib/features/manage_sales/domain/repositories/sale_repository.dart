import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_sale_items/domain/entities/sale_item.dart';
import '../entities/sale.dart';

abstract class SaleRepository {
  Future<List<Sale>> getSales({int page = 1, Map<String, dynamic>? filters});
  Future<Sale> getSaleById(int id);
  Future<List<SaleItem>> getSaleItems({Map<String, dynamic>? filters});
  Future<List<Customer>> getCustomers({Map<String, dynamic>? filters});
  Future<String> createSale(Sale sale);
  Future<String> updateSale(int id, Sale sale);
  Future<String> updateCardReference(int id, String transactionId, {String status = 'completed'});
  Future<String> getSaleInvoiceUrl(int id);
  Future<void> deleteSale(int id);
}
