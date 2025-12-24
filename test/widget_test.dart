import 'package:flutter_test/flutter_test.dart';
import 'package:easy_budget/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const EasyBudgetApp());
    await tester.pumpAndSettle();

    // 앱 타이틀이 표시되는지 확인
    expect(find.text('Easy Budget'), findsOneWidget);
  });
}
