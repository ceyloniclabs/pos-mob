import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import '../repositories/sale_repository.dart';

class GetSaleCustomersUseCase {
  final SaleRepository repository;

  GetSaleCustomersUseCase(this.repository);

  Future<List<Customer>> execute({Map<String, dynamic>? filters}) {
    return repository.getCustomers(filters: filters);
  }
}
