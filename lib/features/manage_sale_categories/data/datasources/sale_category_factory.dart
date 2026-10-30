// Backward compatibility wrapper
import 'package:pos/core/enums.dart';

import 'sale_category_data_source.dart';
import 'sale_category_data_source_factory.dart';

class SaleCategoryFactory {
  static SaleCategoryDataSource create(BackendProviderType type) {
    return SaleCategoryDataSourceFactory.create(type);
  }
}
