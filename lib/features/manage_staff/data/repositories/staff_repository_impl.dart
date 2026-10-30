import 'package:pos/core/models/base_get_list_response_model.dart';
import '../../domain/entities/staff.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_data_source.dart';
import '../models/staff_model.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffDataSource _dataSource;

  StaffRepositoryImpl(this._dataSource);

  @override
  Future<List<Staff>> getStaff({
    String? role,
    String? status,
    String? search,
    int? page,
    int? perPage,
  }) async {
    final models = await _dataSource.getStaff(
      role: role,
      status: status,
      search: search,
      page: page,
      perPage: perPage,
    );
    final entities = models.map((model) => model.toEntity()).toList();
    if (models is PaginatedList<StaffModel>) {
      return PaginatedList<Staff>(entities, meta: models.meta);
    }
    return entities;
  }

  @override
  Future<Staff> getStaffById(int id) async {
    final model = await _dataSource.getStaffById(id);
    return model.toEntity();
  }

  @override
  Future<Staff> createStaff(Staff staff, String password) async {
    final model = await _dataSource.createStaff(StaffModel.fromEntity(staff), password);
    return model.toEntity();
  }

  @override
  Future<Staff> updateStaff(Staff staff, {String? password}) async {
    final model = await _dataSource.updateStaff(StaffModel.fromEntity(staff), password: password);
    return model.toEntity();
  }

  @override
  Future<void> deleteStaff(int id) async {
    await _dataSource.deleteStaff(id);
  }

  @override
  Future<void> updateStaffStatus(int id, bool isActive) async {
    await _dataSource.updateStaffStatus(id, isActive);
  }
}
