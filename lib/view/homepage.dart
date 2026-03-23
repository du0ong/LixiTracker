import 'package:flutter/material.dart';
import '../model/li_xi_transaction.dart';
import '../Repositories/li_xi_repository.dart';
import '../Usecase/get_all_li_xi_usecase.dart';
import '../Usecase/add_li_xi_usecase.dart';
import '../Usecase/delete_li_xi_usecase.dart';
import '../Usecase/update_li_xi_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LiXiRepository _repository = LiXiRepository();
  late GetAllLiXiUseCase _getAllUseCase;
  late AddLiXiUseCase _addUseCase;
  late DeleteLiXiUseCase _deleteUseCase;
  late UpdateLiXiUseCase _updateUseCase;

  List<LiXiTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAllUseCase = GetAllLiXiUseCase(_repository);
    _addUseCase = AddLiXiUseCase(_repository);
    _deleteUseCase = DeleteLiXiUseCase(_repository);
    _updateUseCase = UpdateLiXiUseCase(_repository);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final data = await _getAllUseCase.execute();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  double get _totalReceived => _transactions
      .where((t) => t.type == LiXiType.received)
      .fold(0, (sum, item) => sum + item.amount);

  double get _totalGiven => _transactions
      .where((t) => t.type == LiXiType.given)
      .fold(0, (sum, item) => sum + item.amount);

  // Hàm hiển thị Dialog (Dùng chung cho cả THÊM và SỬA)
  void _showTransactionDialog({LiXiTransaction? editTx}) {
    final isEditing = editTx != null;
    final nameController = TextEditingController(text: isEditing ? editTx.name : '');
    final amountController = TextEditingController(text: isEditing ? editTx.amount.toStringAsFixed(0) : '');
    final categoryController = TextEditingController(text: isEditing ? editTx.category : '');
    DateTime selectedDate = isEditing ? editTx.date : DateTime.now();
    LiXiType selectedType = isEditing ? editTx.type : LiXiType.received;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String formattedDate = '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Cập nhật giao dịch' : 'Thêm giao dịch Lì xì',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên người thân/bạn bè', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Số tiền (VNĐ)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Phân loại (vd: Người thân)', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
                      if (picked != null) setModalState(() => selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Ngày: $formattedDate'), const Icon(Icons.calendar_today, color: Color(0xFFE53935))],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Loại:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Radio<LiXiType>(value: LiXiType.received, groupValue: selectedType, activeColor: Colors.green, onChanged: (v) => setModalState(() => selectedType = v!)),
                      const Text('Nhận'),
                      Radio<LiXiType>(value: LiXiType.given, groupValue: selectedType, activeColor: Colors.orange, onChanged: (v) => setModalState(() => selectedType = v!)),
                      const Text('Cho'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
                      onPressed: () async {
                        if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                          final tx = LiXiTransaction(
                            id: isEditing ? editTx.id : null,
                            name: nameController.text,
                            amount: double.tryParse(amountController.text) ?? 0,
                            date: selectedDate,
                            type: selectedType,
                            category: categoryController.text.isEmpty ? 'Khác' : categoryController.text,
                          );
                          
                          if (isEditing) {
                            await _updateUseCase.execute(tx);
                          } else {
                            await _addUseCase.execute(tx);
                          }
                          
                          if (mounted) {
                            Navigator.pop(context);
                            _loadTransactions();
                          }
                        }
                      },
                      child: Text(
                        isEditing ? 'CẬP NHẬT' : 'LƯU GIAO DỊCH',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: const Text('1. Lì xì Tracker', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => Navigator.pushReplacementNamed(context, '/login'))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTetHeader(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildSummaryCard('Tổng nhận', _totalReceived, const Color(0xFF4CAF50)),
                      const SizedBox(width: 20),
                      _buildSummaryCard('Tổng cho', _totalGiven, const Color(0xFFFFA726)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lịch sử lì xì (Nhấn để sửa, Vuốt để xóa)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _transactions.isEmpty
                      ? const Center(child: Text('Chưa có giao dịch nào'))
                      : ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            return Dismissible(
                              key: Key(tx.id.toString()),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Xác nhận xóa"),
                                      content: Text("Bạn có chắc chắn muốn xóa lịch sử lì xì của ${tx.name} không?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text("XÓA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (direction) async {
                                if (tx.id != null) {
                                  await _deleteUseCase.execute(tx.id!);
                                  _loadTransactions();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Đã xóa lì xì của ${tx.name}')),
                                    );
                                  }
                                }
                              },
                              child: InkWell(
                                onTap: () => _showTransactionDialog(editTx: tx), // Nhấn để SỬA
                                child: _buildTransactionCard(tx),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(), // Thêm mới
        backgroundColor: const Color(0xFFE53935),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    String price = amount.toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String displayAmount = '${price.replaceAllMapped(reg, (Match m) => '${m[1]}.')} ₫';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Text(displayAmount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildTetHeader() {
    return Stack(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Image.network(
            "https://nhomin.com.vn/wp-content/uploads/2016/06/phong-bao-l%C3%AC-x%C3%AC-%C4%91%E1%BA%B9p-2018-2.jpg",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.red),
          ),
        ),
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        const Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🧧 Tết 2026",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Lì Xì Tracker",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(LiXiTransaction tx) {
    final isReceived = tx.type == LiXiType.received;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isReceived ? Colors.green.shade100 : Colors.orange.shade100,
            child: Icon(
              isReceived ? Icons.card_giftcard : Icons.redeem,
              color: isReceived ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "${tx.category} • ${tx.formattedDate}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "${isReceived ? "+" : "-"}${tx.formattedAmount}",
            style: TextStyle(
              color: isReceived ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
