import '../repositories/staff_repository.dart';

class UpdateStaffStatusUseCase {
  final StaffRepository repository;

  UpdateStaffStatusUseCase(this.repository);

  Future<void> execute(int id, bool isActive) {
    if (id <= 0) {
      throw ArgumentError('Invalid staff ID: $id');
    }
    return repository.updateStaffStatus(id, isActive);
  }
}
