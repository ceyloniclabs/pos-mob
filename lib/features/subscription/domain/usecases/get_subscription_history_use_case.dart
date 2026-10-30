import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionHistoryUseCase {
  final SubscriptionRepository _repository;

  GetSubscriptionHistoryUseCase(this._repository);

  Future<List<SubscriptionEntity>> execute() {
    return _repository.getSubscriptionHistory();
  }
}
