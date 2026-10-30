import 'package:pos/features/manage_customers/domain/validators/customer_validator.dart';

class Customer {
  final int? id;
  final int countryId;
  final String name;
  final String phone;
  final String email;
  final String? address;
  final String? profilePhoto;
  final String customerType;
  final String gender;
  final String? nic;
  final String? passportId;
  final String? documentPhotoUrl;
  final String membershipLevel;

  Customer({
    this.id,
    required this.countryId,
    required this.name,
    required this.phone,
    required this.email,
    this.address,
    this.profilePhoto,
    required this.customerType,
    required this.gender,
    this.nic,
    this.passportId,
    this.documentPhotoUrl,
    required this.membershipLevel,
  }) {
    final nameError = CustomerValidator.validateName(name);
    if (nameError != null) {
      throw ArgumentError(nameError);
    }
  }
}
