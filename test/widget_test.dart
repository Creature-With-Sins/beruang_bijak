import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beruang_bijak/main.dart';
import 'package:beruang_bijak/providers/auth_provider.dart';
import 'package:beruang_bijak/providers/category_provider.dart';
import 'package:beruang_bijak/providers/goal_provider.dart';
import 'package:beruang_bijak/providers/transaction_provider.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('BeruangBijakApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const BeruangBijakApp(),
      ),
    );
    expect(find.byType(BeruangBijakApp), findsOneWidget);
  });
}
