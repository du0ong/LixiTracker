import '../Repositories/li_xi_repository.dart';
import '../model/li_xi_transaction.dart';

class UpdateLiXiUseCase {
  final LiXiRepository repository;

  UpdateLiXiUseCase(this.repository);

  Future<void> execute(LiXiTransaction transaction) async {
    await repository.update(transaction);
  }
}
