import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../model/li_xi_transaction.dart';
import '../Repositories/li_xi_repository.dart';
import '../Usecase/get_all_li_xi_usecase.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final LiXiRepository _repository = LiXiRepository();
  late GetAllLiXiUseCase _getAllUseCase;
  List<LiXiTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAllUseCase = GetAllLiXiUseCase(_repository);
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _getAllUseCase.execute();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  String _formatCurrency(double amount) {
    String price = amount.abs().toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = price.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return '${amount < 0 ? "-" : ""}$result ₫';
  }

  @override
  Widget build(BuildContext context) {
    double totalReceived = _transactions
        .where((t) => t.type == LiXiType.received)
        .fold(0, (sum, item) => sum + item.amount);
    double totalGiven = _transactions
        .where((t) => t.type == LiXiType.given)
        .fold(0, (sum, item) => sum + item.amount);
    double totalMoney = totalReceived + totalGiven;
    double balance = totalReceived - totalGiven;

    int countReceived = _transactions.where((t) => t.type == LiXiType.received).length;
    int countGiven = _transactions.where((t) => t.type == LiXiType.given).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Thống kê Lì xì', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE53935),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _transactions.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                        // Card Hiển thị Số dư
                      _buildBalanceCard(balance),
                      const SizedBox(height: 20),
                      
                      // Card Biểu đồ
                      _buildChartCard(totalReceived, totalGiven, totalMoney),
                      const SizedBox(height: 20),
                      
                      // Card Chi tiết số bao
                      _buildCountCard(countReceived, countGiven, totalReceived, totalGiven),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Chưa có dữ liệu để thống kê', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const Text('Tổng tiền dư hiện tại', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(_formatCurrency(balance), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartCard(double received, double given, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.red),
              SizedBox(width: 8),
              Text('Tỉ lệ Thu - Chi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: received == 0 ? 0.1 : received,
                    title: total == 0 ? '' : '${(received / total * 100).toStringAsFixed(1)}%',
                    color: Colors.green.shade400,
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: given == 0 ? 0.1 : given,
                    title: total == 0 ? '' : '${(given / total * 100).toStringAsFixed(1)}%',
                    color: Colors.orange.shade400,
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegendItem('Tiền nhận', Colors.green.shade400, received),
          const SizedBox(height: 12),
          _buildLegendItem('Tiền cho', Colors.orange.shade400, given),
        ],
      ),
    );
  }

  Widget _buildCountCard(int countR, int countG, double sumR, double sumG) {
    return Column(
      children: [
        _buildStatTile(Icons.call_received, Colors.green, 'Nhận lì xì', countR, sumR),
        const SizedBox(height: 12),
        _buildStatTile(Icons.call_made, Colors.orange, 'Cho lì xì', countG, sumG),
      ],
    );
  }

  Widget _buildStatTile(IconData icon, Color color, String title, int count, double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$count bao lì xì', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          Text(_formatCurrency(amount), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, double amount) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const Spacer(),
        Text(_formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
