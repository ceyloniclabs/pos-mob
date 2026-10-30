import 'package:pos/features/manage_sale_items/domain/entities/sale_item.dart';
import '../repositories/sale_repository.dart';

class GetSaleItemsUseCase {
  final SaleRepository repository;

  GetSaleItemsUseCase(this.repository);

  Future<List<SaleItem>> execute({Map<String, dynamic>? filters}) {
    return repository.getSaleItems(filters: filters);
  }
}
