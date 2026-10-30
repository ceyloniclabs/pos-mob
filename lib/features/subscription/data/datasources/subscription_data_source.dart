import '../models/current_subscription_data_model.dart';
import '../models/subscription_model.dart';

abstract class SubscriptionDataSource {
  Future<CurrentSubscriptionDataModel> getCurrentSubscription();
  Future<List<SubscriptionModel>> getSubscriptionHistory();
}
