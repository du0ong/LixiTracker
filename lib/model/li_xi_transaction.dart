enum LiXiType { received, given }

class LiXiTransaction {
  final int? id; // Thêm id để xóa
  final String name;
  final double amount;
  final LiXiType type;
  final DateTime date;
  final String category;

  LiXiTransaction({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
  });

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  String get formattedAmount {
    String price = amount.toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return price.replaceAllMapped(reg, (Match m) => '${m[1]}.') + ' ₫';
  }
}
