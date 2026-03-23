import '../model/li_xi_transaction.dart';
import '../local/database_helper.dart';

class LiXiRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<LiXiTransaction>> getAll() async {
    return await dbHelper.getAllTransactions();
  }

  Future<void> add(LiXiTransaction transaction) async {
    await dbHelper.insert(transaction);
  }

  Future<void> delete(int id) async {
    await dbHelper.delete(id);
  }

  // Thêm phương thức update
  Future<void> update(LiXiTransaction transaction) async {
    if (transaction.id != null) {
      await dbHelper.update(transaction);
    }
  }
}
