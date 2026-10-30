import '../../domain/entities/shop_setting.dart';
import '../../domain/repositories/shop_setting_repository.dart';
import '../datasources/shop_setting_data_source.dart';
import '../models/shop_setting_model.dart';

class ShopSettingRepositoryImpl implements ShopSettingRepository {
  final ShopSettingDataSource dataSource;

  ShopSettingRepositoryImpl(this.dataSource);

  @override
  Future<ShopSetting> getShopSettings() async {
    return await dataSource.getShopSettings();
  }

  @override
  Future<ShopSetting> updateShopSettings(ShopSetting shopSetting) async {
    final model = ShopSettingModel.fromEntity(shopSetting);
    return await dataSource.updateShopSettings(model);
  }
}
