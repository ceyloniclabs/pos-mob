import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  final CustomerRepository repository;

  DeleteCustomerUseCase(this.repository);

  Future<String> execute(int id) {
    return repository.deleteCustomer(id);
  }
}
