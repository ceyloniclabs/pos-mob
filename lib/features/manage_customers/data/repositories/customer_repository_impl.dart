import 'dart:io';

import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';
import 'package:pos/features/manage_customers/data/models/customer_model.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerDataSource _dataSource;

  CustomerRepositoryImpl(this._dataSource);

  @override
  Future<List<Customer>> getCustomers({
    int? page,
    int? perPage,
    String? search,
    String? customerType,
    String? membershipLevel,
  }) async {
    final models = await _dataSource.getCustomers(
      page: page,
      perPage: perPage,
      search: search,
      customerType: customerType,
      membershipLevel: membershipLevel,
    );
    if (models is PaginatedList<CustomerModel>) {
      return PaginatedList<Customer>(models, meta: models.meta);
    }
    return models;
  }

  @override
  Future<Customer> getCustomerById(int id) async {
    return await _dataSource.getCustomerById(id);
  }

  @override
  Future<String> createCustomer(Customer customer) async {
    // Map to CustomerModel if necessary, but since CustomerModel extends Customer
    // we should create a CustomerModel from Customer.
    final customerModel = CustomerModel(
      id: customer.id,
      countryId: customer.countryId,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      profilePhoto: customer.profilePhoto,
      customerType: customer.customerType,
      gender: customer.gender,
      nic: customer.nic,
      passportId: customer.passportId,
      documentPhotoUrl: customer.documentPhotoUrl,
      membershipLevel: customer.membershipLevel,
    );
    return await _dataSource.createCustomer(customerModel);
  }

  @override
  Future<String> updateCustomer(Customer customer) async {
    final customerModel = CustomerModel(
      id: customer.id,
      countryId: customer.countryId,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      profilePhoto: customer.profilePhoto,
      customerType: customer.customerType,
      gender: customer.gender,
      nic: customer.nic,
      passportId: customer.passportId,
      documentPhotoUrl: customer.documentPhotoUrl,
      membershipLevel: customer.membershipLevel,
    );
    return await _dataSource.updateCustomer(customerModel);
  }

  @override
  Future<String> deleteCustomer(int id) async {
    return await _dataSource.deleteCustomer(id);
  }

  @override
  Future<String> uploadCustomerPhoto(File photo) async {
    return await _dataSource.uploadCustomerPhoto(photo);
  }
}
