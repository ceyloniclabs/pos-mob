import '../repositories/staff_repository.dart';

class DeleteStaffUseCase {
  final StaffRepository repository;

  DeleteStaffUseCase(this.repository);

  Future<void> execute(int id) {
    if (id <= 0) {
      throw ArgumentError('Invalid staff ID: $id');
    }
    return repository.deleteStaff(id);
  }
}
