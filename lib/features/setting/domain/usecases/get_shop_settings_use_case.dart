import '../entities/shop_setting.dart';
import '../repositories/shop_setting_repository.dart';

class GetShopSettingsUseCase {
  final ShopSettingRepository repository;

  GetShopSettingsUseCase(this.repository);

  Future<ShopSetting> execute() {
    return repository.getShopSettings();
  }
}
