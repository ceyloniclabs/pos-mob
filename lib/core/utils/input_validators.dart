class AppInputValidator {
  static String? validateText(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.toString().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters long.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }

    if (!RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  static String? validateConfirmPassword(String? pw, String? copw) {
    if (copw == null || copw.isEmpty) {
      return 'Confirm Password is required';
    }

    if (copw != pw) {
      return 'Confirm Password does not match';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegExp = RegExp(r'^\d{10}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (10 digits required)';
    }
    return null;
  }

  static String? validateNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIC is required for local customers';
    }
    return null;
  }

  static String? validatePassport(String? value) {
    if (value == null || value.isEmpty) {
      return 'Passport is required for foreigner customers';
    }
    return null;
  }

  static String? validateDropDown(String? value, String fieldName) {
    if (value == null || value == '-1') {
      return '$fieldName is required';
    }

    return null;
  }
}
