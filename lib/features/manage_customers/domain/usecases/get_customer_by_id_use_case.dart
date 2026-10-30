import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomerByIdUseCase {
  final CustomerRepository _repository;

  GetCustomerByIdUseCase(this._repository);

  Future<Customer> execute(int id) {
    return _repository.getCustomerById(id);
  }
}
