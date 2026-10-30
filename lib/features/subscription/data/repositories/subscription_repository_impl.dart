import '../../domain/entities/current_subscription_data_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionDataSource _dataSource;

  SubscriptionRepositoryImpl(this._dataSource);

  @override
  Future<CurrentSubscriptionDataEntity> getCurrentSubscription() {
    return _dataSource.getCurrentSubscription();
  }

  @override
  Future<List<SubscriptionEntity>> getSubscriptionHistory() {
    return _dataSource.getSubscriptionHistory();
  }
}
