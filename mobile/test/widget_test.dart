// test/widget_test.dart
// Temel duman testi — BandirmaCepteApp ile güncellendi

import 'package:flutter_test/flutter_test.dart';
import 'package:bandirma_cepte/main.dart';
import 'package:bandirma_cepte/services/auth_service.dart';

void main() {
  testWidgets('Ana sayfa açılıyor smoke test', (WidgetTester tester) async {
    final authService = AuthService();
    await tester.pumpWidget(BandirmaCepteApp(authService: authService));
    // Ana başlık görünüyor mu?
    expect(find.text('Bandırma Cepte'), findsWidgets);
  });
}
