import '../entities/current_subscription_data_entity.dart';
import '../repositories/subscription_repository.dart';

class GetCurrentSubscriptionUseCase {
  final SubscriptionRepository _repository;

  GetCurrentSubscriptionUseCase(this._repository);

  Future<CurrentSubscriptionDataEntity> execute() {
    return _repository.getCurrentSubscription();
  }
}
