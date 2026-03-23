import '../Repositories/li_xi_repository.dart';
import '../model/li_xi_transaction.dart';

class GetAllLiXiUseCase {
  final LiXiRepository repository;

  GetAllLiXiUseCase(this.repository);

  Future<List<LiXiTransaction>> execute() async {
    return await repository.getAll();
  }
}
