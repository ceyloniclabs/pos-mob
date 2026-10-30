import '../entities/staff.dart';
import '../repositories/staff_repository.dart';
import '../validators/staff_validator.dart';

class CreateStaffUseCase {
  final StaffRepository repository;

  CreateStaffUseCase(this.repository);

  Future<Staff> execute({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? joinDate,
  }) {
    StaffValidator.validateNameOrThrow(name);
    StaffValidator.validateEmailOrThrow(email);
    StaffValidator.validatePasswordOrThrow(password, isEdit: false);

    final newStaff = Staff(
      id: 0,
      name: name,
      email: email,
      role: 'staff',
      phoneNumber: phoneNumber,
      joinDate: joinDate,
    );

    return repository.createStaff(newStaff, password);
  }
}
