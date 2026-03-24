import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Hình nền (Lấy từ file cục bộ lib/image/img.png)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/image/img.png"), 
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          
          // Lớp phủ Gradient để chữ và card nổi bật hơn
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3), // Đẩy card xuống vị trí giống trong ảnh
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95), // Trắng mờ nhẹ
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Mừng Xuân 2026",
                          style: TextStyle(
                            color: Color(0xFFC62828), // Màu đỏ đậm sang trọng
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "QUẢN LÝ LÌ XÌ MAY MẮN",
                          style: TextStyle(
                            color: Colors.grey, 
                            fontSize: 10, 
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Username Field
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFC62828), size: 22),
                            hintText: "Tên đăng nhập",
                            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Color(0xFFC62828), width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFC62828), size: 22),
                            hintText: "Mật khẩu",
                            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey),
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Color(0xFFC62828), width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 4,
                              shadowColor: Colors.red.withOpacity(0.5),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: const Text(
                              "Đăng nhập ngay",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 2), 
                
                // Footer
                const Text(
                  "Chúc mừng năm mới - An khang thịnh vượng",
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)]
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
