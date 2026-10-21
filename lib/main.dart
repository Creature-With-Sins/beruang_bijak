import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import untuk lokalisasi Material
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import provider & screen aplikasi Beruang Bijak
import 'providers/transaction_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

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

    // Jika user sudah terautentikasi (login)
    if (authProvider.isAuthenticated) {
      final username = authProvider.currentUsername!;

      // Muat data transaksi spesifik milik user yang sedang login setelah frame selesai dirender
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransactionProvider>().loadTransactionsForUser(username);
      });

      return const MainNavigationScreen();
    }

    // Jika belum login, tampilkan LoginScreen
    return const LoginScreen();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
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
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Beruang Bijak',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // Tema Terang
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),

      // Tema Gelap (Disesuaikan agar full gelap)
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),

      // Pendaftaran Delegasi Lokalisasi Bahasa (Penting untuk DatePicker & Kalender)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // English
      ],

      home: const AuthGate(),
    );
  }
}
