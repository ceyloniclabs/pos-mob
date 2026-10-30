import '../entities/current_subscription_data_entity.dart';
import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<CurrentSubscriptionDataEntity> getCurrentSubscription();
  Future<List<SubscriptionEntity>> getSubscriptionHistory();
}
