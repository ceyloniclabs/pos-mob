import '../entities/staff.dart';

abstract class StaffRepository {
  Future<List<Staff>> getStaff({
    String? role,
    String? status,
    String? search,
    int? page,
    int? perPage,
  });

  Future<Staff> getStaffById(int id);

  Future<Staff> createStaff(Staff staff, String password);

  Future<Staff> updateStaff(Staff staff, {String? password});

  Future<void> deleteStaff(int id);

  Future<void> updateStaffStatus(int id, bool isActive);
}
