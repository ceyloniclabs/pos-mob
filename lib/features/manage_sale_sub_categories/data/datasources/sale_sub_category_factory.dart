// Backward compatibility wrapper
import 'package:pos/core/enums.dart';

import 'sale_sub_category_data_source.dart';
import 'sale_sub_category_data_source_factory.dart';

class SaleSubCategoryFactory {
  static SaleSubCategoryDataSource create(BackendProviderType type) {
    return SaleSubCategoryDataSourceFactory.create(type);
  }
}
