import '../Repositories/li_xi_repository.dart';
import '../model/li_xi_transaction.dart';

class AddLiXiUseCase {
  final LiXiRepository repository;

  AddLiXiUseCase(this.repository);

  // Chuyển sang Future<void> để có thể await
  Future<void> execute(LiXiTransaction transaction) async {
    await repository.add(transaction);
  }
}
