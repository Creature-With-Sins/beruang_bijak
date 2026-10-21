import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onDashboardTap;

  const CustomDrawer({super.key, required this.onDashboardTap});

  void _showLogoutDialog(BuildContext parentContext) {
    showDialog<void>(
      context: parentContext,
      builder:
          (dialogContext) => AlertDialog(
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
                  // 1. Tutup dialog
                  Navigator.pop(dialogContext);

                  // 2. Tutup Drawer
                  Navigator.pop(parentContext);

                  // 3. Reset data transaksi di memori
                  parentContext.read<TransactionProvider>().clearOnLogout();

                  // 4. Jalankan logout dari AuthProvider
                  await parentContext.read<AuthProvider>().logout();
                },
                child: const Text('Logout'),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF087F8C), Color(0xFF16A6A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_logo.jpeg',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Beruang Bijak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Halo, $username!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kelola keuangan dengan bijak',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                onDashboardTap();
              },
            ),
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
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  _showLogoutDialog(context);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Beruang Bijak',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}