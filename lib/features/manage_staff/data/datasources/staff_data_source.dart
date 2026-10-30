import '../models/staff_model.dart';

abstract class StaffDataSource {
  Future<List<StaffModel>> getStaff({
    String? role,
    String? status,
    String? search,
    int? page,
    int? perPage,
  });

  Future<StaffModel> getStaffById(int id);

  Future<StaffModel> createStaff(StaffModel staffModel, String password);

  Future<StaffModel> updateStaff(StaffModel staffModel, {String? password});

  Future<void> deleteStaff(int id);

  Future<void> updateStaffStatus(int id, bool isActive);
}
