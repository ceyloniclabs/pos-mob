class StaffValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Staff name is required';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? validatePassword(String? password, {bool isEdit = false}) {
    if (!isEdit && (password == null || password.trim().isEmpty)) {
      return 'Password is required';
    }
    if (password != null && password.isNotEmpty && password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static void validateNameOrThrow(String name) {
    final error = validateName(name);
    if (error != null) throw ArgumentError(error);
  }

  static void validateEmailOrThrow(String email) {
    final error = validateEmail(email);
    if (error != null) throw ArgumentError(error);
  }

  static void validatePasswordOrThrow(String? password, {bool isEdit = false}) {
    final error = validatePassword(password, isEdit: isEdit);
    if (error != null) throw ArgumentError(error);
  }
}
