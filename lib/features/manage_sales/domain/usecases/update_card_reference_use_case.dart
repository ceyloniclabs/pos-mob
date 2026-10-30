import '../repositories/sale_repository.dart';

class UpdateCardReferenceUseCase {
  final SaleRepository repository;

  UpdateCardReferenceUseCase(this.repository);

  Future<String> execute(
    int id,
    String transactionId, {
    String status = 'completed',
  }) {
    return repository.updateCardReference(id, transactionId, status: status);
  }
}
