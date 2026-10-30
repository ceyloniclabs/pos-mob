import '../entities/shop_setting.dart';
import '../repositories/shop_setting_repository.dart';

class UpdateShopSettingsUseCase {
  final ShopSettingRepository repository;

  UpdateShopSettingsUseCase(this.repository);

  Future<ShopSetting> execute(ShopSetting shopSetting) {
    return repository.updateShopSettings(shopSetting);
  }
}
