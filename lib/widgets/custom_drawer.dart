import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/auth_provider.dart';
import '../screens/goals_screen.dart';
import '../screens/manage_categories_screen.dart';
import '../screens/pdf_preview_screen.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onDashboardTap;

  const CustomDrawer({super.key, required this.onDashboardTap});

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 32),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AuthProvider>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF087F8C), size: 36),
        title: const Text('Tentang Beruang Bijak'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beruang Bijak adalah aplikasi pencatatan dan pengelolaan keuangan pribadi yang berfokus pada kemudahan, keamanan data lokal (offline-first), serta laporan visual interaktif.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Fitur Utama:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 4),
            Text(
              '• Pencatatan Pemasukan & Pengeluaran\n'
              '• Laporan Arus Kas Bulanan & Visualisasi Diagram\n'
              '• Cetak & Unduh Laporan PDF & CSV Excel\n'
              '• 🎯 Celengan Impian (Savings Goals)\n'
              '• 🏷️ Kelola Kategori Kustom Dinamis\n'
              '• Batas Budget Harian & Bulanan\n'
              '• Mode Gelap & Terang Menyeluruh',
              style: TextStyle(fontSize: 12, height: 1.3),
            ),
            SizedBox(height: 12),
            Text(
              'Versi: 1.1.0 (Vibecoded Edition)',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF087F8C),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final username = authProvider.currentUsername ?? 'Pengguna';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF087F8C), Color(0xFF16A6A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.white,
                          child: Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : 'B',
                            style: const TextStyle(
                              color: Color(0xFF087F8C),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Beruang Bijak',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Halo, $username! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Kelola keuangan bijak',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard_rounded),
                    title: const Text('Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      onDashboardTap();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.savings_rounded, color: Color(0xFF087F8C)),
                    title: const Text('Celengan Impian'),
                    subtitle: const Text('Target tabungan & cita-cita'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GoalsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.category_rounded, color: Color(0xFF087F8C)),
                    title: const Text('Kelola Kategori'),
                    subtitle: const Text('Kategori transaksi dinamis'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF087F8C)),
                    title: const Text('Laporan PDF & CSV'),
                    subtitle: const Text('Cetak & bagikan laporan bulanan'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfPreviewScreen(initialMonth: DateTime.now()),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                    title: const Text('Tema'),
                    subtitle: Text(isDarkMode ? 'Mode Gelap' : 'Mode Terang'),
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (_) {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                    ),
                    onTap: () {
                      context.read<ThemeProvider>().toggleTheme();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Tentang Aplikasi'),
                    subtitle: const Text('Informasi fitur & versi'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Beruang Bijak • v1.1.0',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
