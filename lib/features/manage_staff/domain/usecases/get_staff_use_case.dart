import '../entities/staff.dart';
import '../repositories/staff_repository.dart';

class GetStaffUseCase {
  final StaffRepository repository;

  GetStaffUseCase(this.repository);

  Future<List<Staff>> execute({
    String? role,
    String? status,
    String? search,
    int? page,
    int? perPage,
  }) {
    return repository.getStaff(
      role: role,
      status: status,
      search: search,
      page: page,
      perPage: perPage,
    );
  }
}
