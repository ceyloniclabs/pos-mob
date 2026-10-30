import 'dart:io';

import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers({
    int? page,
    int? perPage,
    String? search,
    String? customerType,
    String? membershipLevel,
  });
  Future<Customer> getCustomerById(int id);
  Future<String> createCustomer(Customer customer);
  Future<String> updateCustomer(Customer customer);
  Future<String> deleteCustomer(int id);
  Future<String> uploadCustomerPhoto(File photo);
}
