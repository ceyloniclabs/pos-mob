import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_sale_items/data/models/sale_item_inventory_model.dart';
import 'package:pos/features/manage_sale_items/domain/entities/sale_item.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source.dart';
import 'package:pos/features/manage_sales/data/models/sale_model.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';
import 'package:pos/features/manage_sales/domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleDataSource _dataSource;

  SaleRepositoryImpl(this._dataSource);

  @override
  Future<List<Sale>> getSales({int page = 1, Map<String, dynamic>? filters}) async {
    final models = await _dataSource.getSales(page, filters: filters);
    final entities = models.map((m) => m.toEntity()).toList();
    if (models is PaginatedList<SaleModel>) {
      return PaginatedList<Sale>(entities, meta: models.meta);
    }
    return entities;
  }

  @override
  Future<Sale> getSaleById(int id) async {
    final model = await _dataSource.getSaleById(id);
    return model.toEntity();
  }

  @override
  Future<List<SaleItem>> getSaleItems({Map<String, dynamic>? filters}) async {
    final models = await _dataSource.getSaleItems(filters: filters);
    final entities = models.map((m) => m.toEntity()).toList();
    if (models is PaginatedList<SaleItemInventoryModel>) {
      return PaginatedList<SaleItem>(entities, meta: models.meta);
    }
    return entities;
  }

  @override
  Future<List<Customer>> getCustomers({Map<String, dynamic>? filters}) async {
    return await _dataSource.getCustomers(filters: filters);
  }

  @override
  Future<String> createSale(Sale sale) async {
    final model = SaleModel.fromEntity(sale);
    return await _dataSource.createSale(model);
  }

  @override
  Future<String> updateSale(int id, Sale sale) async {
    final model = SaleModel.fromEntity(sale);
    return await _dataSource.updateSale(id, model);
  }

  @override
  Future<String> updateCardReference(
    int id,
    String transactionId, {
    String status = 'completed',
  }) async {
    return await _dataSource.updateCardReference(id, transactionId, status: status);
  }

  @override
  Future<String> getSaleInvoiceUrl(int id) {
    return _dataSource.getSaleInvoiceUrl(id);
  }

  @override
  Future<void> deleteSale(int id) async {
    await _dataSource.deleteSale(id);
  }
}
