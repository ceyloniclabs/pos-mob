import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/models/base_get_single_response_model.dart';
import 'package:pos/features/manage_customers/data/models/customer_model.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';

class CustomerLaravelDataSourceImpl implements CustomerDataSource {
  final ApiService _apiService;

  CustomerLaravelDataSourceImpl(this._apiService);

  @override
  Future<List<CustomerModel>> getCustomers(
      {int? page,
      int? perPage,
      String? search,
      String? customerType,
      String? membershipLevel}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (customerType != null &&
          customerType.isNotEmpty &&
          customerType != 'all') {
        queryParams['customer_type'] = customerType;
      }
      if (membershipLevel != null &&
          membershipLevel.isNotEmpty &&
          membershipLevel != 'all') {
        queryParams['membership_level'] = membershipLevel;
      }

      final response = await _apiService.getRequest(
        EndPoints.customer,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final baseResponse = BaseGetListResponseModel<CustomerModel>.fromJson(
        response,
        (data) => CustomerModel.fromJson(data),
      );

      if (baseResponse.success) {
        return baseResponse.data;
      }
    } catch (e) {
      return Future.error(e);
    }
    return [];
  }

  @override
  Future<CustomerModel> getCustomerById(int id) async {
    try {
      final response = await _apiService.getRequest("${EndPoints.customer}/$id");
      final baseResponse = BaseGetSingleResponseModel<CustomerModel>.fromJson(
        response,
        (data) => CustomerModel.fromJson(data),
      );

      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      } else {
        throw Exception(baseResponse.message ?? 'Customer not found');
      }
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }

  @override
  Future<String> createCustomer(CustomerModel customer) async {
    try {
      FormData formData = FormData.fromMap({
        'country_id': customer.countryId,
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        if (customer.address != null) 'address': customer.address,
        'customer_type': customer.customerType,
        'gender': customer.gender,
        if (customer.nic != null) 'nic': customer.nic,
        if (customer.passportId != null) 'passport_id': customer.passportId,
        'membership_level': customer.membershipLevel,
      });

      if (customer.profilePhoto != null &&
          File(customer.profilePhoto!).existsSync()) {
        formData.files.add(MapEntry(
          'profile_photo',
          await MultipartFile.fromFile(customer.profilePhoto!),
        ));
      }

      if (customer.documentPhotoUrl != null &&
          File(customer.documentPhotoUrl!).existsSync()) {
        formData.files.add(MapEntry(
          'document_photo',
          await MultipartFile.fromFile(customer.documentPhotoUrl!),
        ));
      }

      // Create customer with multipart form data
      final response = await _apiService.postRequest(
        EndPoints.customer,
        data: formData,
      );

      final baseResponse = BaseGetSingleResponseModel<CustomerModel>.fromJson(
        response,
        (data) => CustomerModel.fromJson(data),
      );

      if (baseResponse.success) {
        return baseResponse.message!;
      } else {
        throw Exception(baseResponse.message);
      }
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  @override
  Future<String> updateCustomer(CustomerModel customer) async {
    try {
      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        'country_id': customer.countryId,
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        if (customer.address != null) 'address': customer.address,
        'customer_type': customer.customerType,
        'gender': customer.gender,
        if (customer.nic != null) 'nic': customer.nic,
        if (customer.passportId != null) 'passport_id': customer.passportId,
        'membership_level': customer.membershipLevel,
      });

      if (customer.profilePhoto != null &&
          File(customer.profilePhoto!).existsSync()) {
        formData.files.add(MapEntry(
          'profile_photo',
          await MultipartFile.fromFile(customer.profilePhoto!),
        ));
      }

      if (customer.documentPhotoUrl != null &&
          File(customer.documentPhotoUrl!).existsSync()) {
        formData.files.add(MapEntry(
          'document_photo',
          await MultipartFile.fromFile(customer.documentPhotoUrl!),
        ));
      }

      final response = await _apiService.postRequest(
        "${EndPoints.customer}/${customer.id}",
        data: formData,
      );

      log("updatecustomer response $response");

      final baseResponse = BaseGetSingleResponseModel<CustomerModel>.fromJson(
        response,
        (data) => CustomerModel.fromJson(data),
      );

      if (baseResponse.success) {
        return baseResponse.message!;
      } else {
        log(baseResponse.message!);
        throw Exception(baseResponse.message);
      }
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  @override
  Future<String> deleteCustomer(int id) async {
    final response =
        await _apiService.deleteRequest("${EndPoints.customer}/$id");

    final baseResponse = BaseGetSingleResponseModel<CustomerModel>.fromJson(
      response,
      (data) => CustomerModel.fromJson(data),
    );

    if (baseResponse.success) {
      return baseResponse.message!;
    } else {
      throw Exception(baseResponse.message);
    }
  }

  @override
  Future<String> uploadCustomerPhoto(File photo) async {
    try {
      final response = await _apiService.uploadFile(
        EndPoints.uploadPhoto,
        photo,
        fieldName: 'customer_photo',
      );

      final baseResponse = BaseGetSingleResponseModel<String>.fromJson(
        response,
        (data) => data.toString(),
      );

      if (baseResponse.success) {
        return baseResponse.data!;
      } else {
        throw Exception(baseResponse.message);
      }
    } catch (e) {
      throw Exception('Failed to upload customer photo: $e');
    }
  }
}
