// 🔹 Bu dosya Flutter widget testleri için örnek bir test içerir.
// 🔹 WidgetTester kullanarak widget'lar ile etkileşim kurabilir,
//    metinleri kontrol edebilir ve widget özelliklerini doğrulayabilirsiniz.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/main.dart';

void main() {
  // 🔹 Basit bir smoke test: sayacın doğru çalıştığını test eder
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 🔹 Uygulamayı oluştur ve bir frame tetikle
    await tester.pumpWidget(HealthApp());
    // 🔹 Başlangıçta sayacın 0 olduğunu doğrula
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    // 🔹 '+' ikonuna tıkla ve frame tetikle
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    // 🔹 Sayacın 1 arttığını doğrula
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
