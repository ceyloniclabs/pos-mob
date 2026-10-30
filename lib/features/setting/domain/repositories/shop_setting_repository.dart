import '../entities/shop_setting.dart';

/// Abstract repository contract for shop settings (setting domain layer).
abstract class ShopSettingRepository {
  Future<ShopSetting> getShopSettings();
  Future<ShopSetting> updateShopSettings(ShopSetting shopSetting);
}
