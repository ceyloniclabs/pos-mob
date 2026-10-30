import '../entities/staff.dart';
import '../repositories/staff_repository.dart';
import '../validators/staff_validator.dart';

class UpdateStaffUseCase {
  final StaffRepository repository;

  UpdateStaffUseCase(this.repository);

  Future<Staff> execute({
    required Staff existingStaff,
    required String name,
    required String email,
    String? password,
    String? phoneNumber,
    String? joinDate,
  }) {
    StaffValidator.validateNameOrThrow(name);
    StaffValidator.validateEmailOrThrow(email);
    if (password != null && password.isNotEmpty) {
      StaffValidator.validatePasswordOrThrow(password, isEdit: true);
    }

    final updatedStaff = existingStaff.copyWith(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      joinDate: joinDate,
    );

    return repository.updateStaff(updatedStaff, password: password);
  }
}
