import 'package:flutter_test/flutter_test.dart';
import 'package:pe/view/app.dart'; // Thay đổi import ở đây

void main() {
  testWidgets('Lixi Tracker smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Kiểm tra xem tiêu đề có hiển thị không
    expect(find.text('1. Lì xì Tracker'), findsNothing); // Ban đầu ở trang login
  });
}
