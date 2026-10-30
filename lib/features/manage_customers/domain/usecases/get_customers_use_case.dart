import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  Future<List<Customer>> execute({
    int? page,
    int? perPage,
    String? search,
    String? customerType,
    String? membershipLevel,
  }) {
    return repository.getCustomers(
      page: page,
      perPage: perPage,
      search: search,
      customerType: customerType,
      membershipLevel: membershipLevel,
    );
  }
}
