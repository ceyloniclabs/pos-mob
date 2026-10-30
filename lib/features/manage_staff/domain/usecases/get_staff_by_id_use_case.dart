import '../entities/staff.dart';
import '../repositories/staff_repository.dart';

class GetStaffByIdUseCase {
  final StaffRepository repository;

  GetStaffByIdUseCase(this.repository);

  Future<Staff> execute(int id) {
    return repository.getStaffById(id);
  }
}
