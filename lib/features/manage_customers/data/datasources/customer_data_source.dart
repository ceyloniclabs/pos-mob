import 'dart:io';

import 'package:pos/features/manage_customers/data/models/customer_model.dart';

abstract class CustomerDataSource {
  Future<List<CustomerModel>> getCustomers(
      {int? page,
      int? perPage,
      String? search,
      String? customerType,
      String? membershipLevel});
  Future<CustomerModel> getCustomerById(int id);
  Future<String> createCustomer(CustomerModel customer);
  Future<String> updateCustomer(CustomerModel customer);
  Future<String> deleteCustomer(int id);
  Future<String> uploadCustomerPhoto(File photo);
}
