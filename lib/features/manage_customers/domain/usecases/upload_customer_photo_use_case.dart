import 'dart:io';

import '../repositories/customer_repository.dart';

class UploadCustomerPhotoUseCase {
  final CustomerRepository repository;

  UploadCustomerPhotoUseCase(this.repository);

  Future<String> execute(File photo) {
    return repository.uploadCustomerPhoto(photo);
  }
}
