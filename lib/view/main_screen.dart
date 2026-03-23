import 'package:flutter/material.dart';
import 'homepage.dart';
import 'statistics_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Danh sách 2 màn hình
  final List<Widget> _pages = [
    const HomePage(),
    const StatisticsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Hiển thị trang tương ứng
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Thống kê',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE53935), // Màu đỏ Tết cho nút đang chọn
        onTap: _onItemTapped,
      ),
    );
  }
}
