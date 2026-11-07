import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sss_shop/core/widgets/ui.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  testWidgets('StatusPill shows Hinglish label', (tester) async {
    await tester.pumpWidget(_wrap(const StatusPill('Repair in Progress')));
    expect(find.text('Repair chalu'), findsOneWidget);
  });

  testWidgets('EmptyState shows title and message', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState(title: 'Koi repair nahi', message: 'Filter badlein')));
    expect(find.text('Koi repair nahi'), findsOneWidget);
    expect(find.text('Filter badlein'), findsOneWidget);
  });

  testWidgets('KvList renders all rows', (tester) async {
    await tester.pumpWidget(_wrap(const KvList([('Phone', 'Vivo Y20'), ('Lock', '1234')])));
    expect(find.text('Vivo Y20'), findsOneWidget);
    expect(find.text('Lock'), findsOneWidget);
  });
}
