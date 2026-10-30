import '../../../../core/utils/input_validators.dart';

class CustomerValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }
    if (name.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    return AppInputValidator.validatePhoneNumber(phone);
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    return AppInputValidator.validateEmail(email);
  }

  static String? validateNic(String? nic) {
    if (nic == null || nic.trim().isEmpty) {
      return 'NIC is required';
    }
    return AppInputValidator.validateNIC(nic);
  }

  static String? validatePassport(String? passport) {
    if (passport == null || passport.trim().isEmpty) {
      return 'Passport is required';
    }
    return AppInputValidator.validatePassport(passport);
  }
}
