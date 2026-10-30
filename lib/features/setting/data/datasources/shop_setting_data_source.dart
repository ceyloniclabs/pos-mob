import '../models/shop_setting_model.dart';

abstract class ShopSettingDataSource {
  Future<ShopSettingModel> getShopSettings();
  Future<ShopSettingModel> updateShopSettings(ShopSettingModel model);
}
