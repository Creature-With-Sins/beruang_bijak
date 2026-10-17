import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import untuk inisialisasi format tanggal lokal
import 'package:beruang_bijak/screens/login_screen.dart';

// Import provider & screen aplikasi Pocket Budget
import 'providers/transaction_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'package:beruang_bijak/providers/auth_provider.dart';

// ThemeProvider untuk fitur Dark/Light Mode
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const MainNavigationScreen();
    }

    return const LoginScreen();
  }
}

void main() async {
  // Pastikan binding Flutter sudah diinisialisasi sebelum panggilan async
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi format data tanggal lokal bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        // Provider utama untuk transaksi keuangan
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        // Provider untuk pengaturan tema aplikasi
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PocketBudgetApp(),
    ),
  );
}

class PocketBudgetApp extends StatelessWidget {
  const PocketBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengakses state dari ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Pocket Budget',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      // Pintu utama aplikasi mengarah ke BottomNavigationBar
      home: const MainNavigationScreen(),
    );
  }
}