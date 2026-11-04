import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/category_provider.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context, TransactionType defaultType) {
    final textController = TextEditingController();
    TransactionType selectedType = defaultType;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.category_rounded, color: Color(0xFF087F8C)),
                  SizedBox(width: 8),
                  Text('Tambah Kategori'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipe Kategori',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text('Pengeluaran'),
                          icon: Icon(Icons.arrow_upward_rounded),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text('Pemasukan'),
                          icon: Icon(Icons.arrow_downward_rounded),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (val) {
                        setDialogState(() {
                          selectedType = val.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nama Kategori',
                        hintText: 'Misal: Sedekah, Kursus, Gadget',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF087F8C),
                  ),
                  onPressed: () async {
                    final name = textController.text.trim();
                    if (name.isEmpty) return;

                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(dialogCtx);
                    final provider = context.read<CategoryProvider>();
                    final success = await provider.addCategory(selectedType, name);

                    nav.pop();
                    if (success) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Kategori "$name" berhasil ditambahkan!'),
                          backgroundColor: const Color(0xFF087F8C),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Kategori "$name" sudah ada!'),
                          backgroundColor: Colors.orange.shade800,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, TransactionType type, String name) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32),
        title: const Text('Hapus Kategori?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus kategori kustom "$name"?\n'
          'Transaksi lama dengan kategori ini tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(dialogCtx);
              nav.pop();
              await context.read<CategoryProvider>().removeCategory(type, name);
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Kategori "$name" berhasil dihapus.'),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'belanja':
        return Icons.shopping_bag_rounded;
      case 'hiburan':
        return Icons.movie_rounded;
      case 'kesehatan':
        return Icons.medical_services_rounded;
      case 'pendidikan':
        return Icons.school_rounded;
      case 'tagihan':
        return Icons.receipt_long_rounded;
      case 'gaji':
        return Icons.account_balance_wallet_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      case 'investasi':
        return Icons.trending_up_rounded;
      case 'pemasukan':
        return Icons.payments_rounded;
      default:
        return Icons.label_outline_rounded;
    }
  }

  Widget _buildCategoryList(TransactionType type) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.getCategories(type);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isCustom = categoryProvider.isCustomCategory(type, cat);

        return Card(
          elevation: 0,
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: type == TransactionType.income
                  ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))
                  : (isDark ? const Color(0xFF451A1A) : const Color(0xFFFEE2E2)),
              child: Icon(
                _getCategoryIcon(cat),
                color: type == TransactionType.income
                    ? const Color(0xFF16A36A)
                    : const Color(0xFFDC2626),
                size: 20,
              ),
            ),
            title: Text(
              cat,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCustom
                        ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
                        : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE0F2FE)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isCustom ? 'Kustom' : 'Bawaan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCustom
                          ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309))
                          : (isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1)),
                    ),
                  ),
                ),
                if (isCustom) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                    tooltip: 'Hapus kategori',
                    onPressed: () => _confirmDeleteCategory(context, type, cat),
                  ),
                ] else ...[
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF087F8C),
          indicatorColor: const Color(0xFF087F8C),
          tabs: const [
            Tab(text: 'Pengeluaran', icon: Icon(Icons.shopping_bag_outlined)),
            Tab(text: 'Pemasukan', icon: Icon(Icons.account_balance_wallet_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(TransactionType.expense),
          _buildCategoryList(TransactionType.income),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF087F8C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kategori'),
        onPressed: () {
          final currentType = _tabController.index == 0
              ? TransactionType.expense
              : TransactionType.income;
          _showAddCategoryDialog(context, currentType);
        },
      ),
    );
  }
}

