import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('2048 Merge smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Merge2048App());

    // 초기 타일 확인 (2개의 타일이 생성되어야 함)
    expect(find.text('2'), findsWidgets);

    // 점수 초기값 확인
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // 새 게임 버튼 확인
    expect(find.text('NEW GAME'), findsOneWidget);
  });
}
