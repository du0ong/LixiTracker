import '../Repositories/li_xi_repository.dart';

class DeleteLiXiUseCase {
  final LiXiRepository repository;

  DeleteLiXiUseCase(this.repository);

  Future<void> execute(int id) async {
    await repository.delete(id);
  }
}
