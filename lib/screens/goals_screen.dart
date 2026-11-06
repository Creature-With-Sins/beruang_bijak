import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import '../models/transaction_model.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_formatters.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String _filter = 'all'; // 'all', 'active', 'completed'

  void _showAddEditGoalSheet({GoalModel? editGoal}) {
    final titleController = TextEditingController(text: editGoal?.title ?? '');
    final targetController = TextEditingController(
      text: editGoal != null
          ? (editGoal.targetAmount % 1 == 0
              ? editGoal.targetAmount.toInt().toString()
              : editGoal.targetAmount.toString())
          : '',
    );
    final initialController = TextEditingController();
    final noteController = TextEditingController(text: editGoal?.note ?? '');
    DateTime? selectedDate = editGoal?.targetDate;
    String selectedCategory = editGoal?.category ?? 'Elektronik';
    bool isSyncedWithWallet = editGoal?.isSyncedWithWallet ?? true;

    const categories = [
      'Elektronik',
      'Kendaraan',
      'Liburan',
      'Pendidikan',
      'Darurat',
      'Investasi',
      'Rumah Tangga',
      'Lainnya',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final isEditing = editGoal != null;

            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.savings_rounded, color: Color(0xFF087F8C), size: 24),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Edit Celengan' : 'Celengan Impian Baru',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Nama Impian',
                        hintText: 'Misal: Beli Laptop Baru, Liburan ke Bali',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Target Tabungan (Rp)',
                        hintText: 'Misal: 5000000',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!isEditing) ...[
                      TextField(
                        controller: initialController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Setoran Awal (Opsional)',
                          hintText: '0',
                          prefixText: 'Rp ',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Saldo Terkumpul Saat Ini', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  AppFormatters.formatCurrency(editGoal.savedAmount),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF16A36A)),
                                ),
                              ],
                            ),
                            const Text(
                              'Gunakan tombol Tabung / Tarik',
                              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSyncedWithWallet
                              ? const Color(0xFF087F8C).withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Icon(
                              isSyncedWithWallet ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                              size: 18,
                              color: isSyncedWithWallet ? const Color(0xFF087F8C) : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Sinkronkan dengan Kas Utama',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            isSyncedWithWallet
                                ? 'Setiap kali menabung otomatis potong saldo kas, dan setiap kali ditarik otomatis dikembalikan ke dompet kas.'
                                : 'Mode Mandiri: Tabungan dicatat terpisah (misal celengan fisik di kamar) tanpa menyentuh kas utama.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        value: isSyncedWithWallet,
                        onChanged: (val) {
                          setSheetState(() => isSyncedWithWallet = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori Impian',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 90)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                          helpText: 'Pilih target waktu tercapai',
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? 'Tenggat Waktu: Belum diatur'
                                  : 'Target: ${AppFormatters.formatDate(selectedDate!)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: selectedDate == null
                                    ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            const Icon(Icons.calendar_today_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Catatan Tambahan (Opsional)',
                        hintText: 'Misal: Nabung Rp 50rb per minggu',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF087F8C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final target = double.tryParse(targetController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
                          final saved = double.tryParse(initialController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

                          if (title.isEmpty || target <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama dan target tabungan harus diisi dengan benar.')),
                            );
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(sheetCtx);
                          final goalProv = context.read<GoalProvider>();
                          final txProv = context.read<TransactionProvider>();

                          if (isEditing) {
                            final updated = editGoal.copyWith(
                              title: title,
                              targetAmount: target,
                              savedAmount: editGoal.savedAmount, // Pertahankan saldo yang sudah ada
                              category: selectedCategory,
                              targetDate: selectedDate,
                              note: noteController.text.trim(),
                              isSyncedWithWallet: isSyncedWithWallet,
                            );
                            await goalProv.updateGoal(updated);
                          } else {
                            await goalProv.addGoal(
                              title: title,
                              targetAmount: target,
                              initialAmount: saved,
                              category: selectedCategory,
                              targetDate: selectedDate,
                              note: noteController.text.trim(),
                              isSyncedWithWallet: isSyncedWithWallet,
                            );

                            if (saved > 0 && isSyncedWithWallet) {
                              await txProv.addTransaction(
                                title: 'Setoran Awal: $title',
                                amount: saved,
                                type: TransactionType.expense,
                                category: 'Tabungan',
                                date: DateTime.now(),
                                note: 'Alokasi ke Celengan Impian ($title)',
                              );
                            }
                          }

                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Celengan berhasil diperbarui!' : 'Celengan impian berhasil dibuat! 🎯'),
                              backgroundColor: const Color(0xFF087F8C),
                            ),
                          );
                        },
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Mulai Menabung Sekarang',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDepositSheet(GoalModel goal) {
    final amountController = TextEditingController();
    final remaining = goal.remainingAmount;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF16A36A), size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Nabung: ${goal.title}',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    Text(
                      'Terkumpul saat ini: ${AppFormatters.formatCurrency(goal.savedAmount)} dari ${AppFormatters.formatCurrency(goal.targetAmount)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Nominal Setoran (Rp)',
                        hintText: 'Misal: 50000',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...[20000, 50000, 100000, 200000, 500000].map((preset) {
                          return ActionChip(
                            label: Text('+${AppFormatters.formatCurrency(preset)}'),
                            onPressed: () {
                              final curr = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                              amountController.text = (curr + preset).toInt().toString();
                            },
                          );
                        }),
                        if (remaining > 0)
                          ActionChip(
                            avatar: const Icon(Icons.flag_rounded, size: 14),
                            label: Text('Sisa Target (${AppFormatters.formatCurrency(remaining)})'),
                            onPressed: () {
                              amountController.text = remaining.toInt().toString();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: goal.isSyncedWithWallet
                            ? const Color(0xFF087F8C).withValues(alpha: 0.1)
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: goal.isSyncedWithWallet
                              ? const Color(0xFF087F8C).withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            goal.isSyncedWithWallet ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                            size: 18,
                            color: goal.isSyncedWithWallet ? const Color(0xFF087F8C) : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              goal.isSyncedWithWallet
                                  ? 'Terhubung Kas Utama: Setoran ini otomatis memotong saldo dompet kas Anda (Kategori: Tabungan).'
                                  : 'Celengan Mandiri: Setoran ini hanya mencatat progress impian tanpa memotong saldo kas utama.',
                              style: TextStyle(
                                fontSize: 12,
                                color: goal.isSyncedWithWallet
                                    ? (isDark ? Colors.tealAccent.shade100 : const Color(0xFF087F8C))
                                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF16A36A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final val = double.tryParse(amountController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
                          if (val <= 0) return;

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(sheetCtx);
                          final goalProv = context.read<GoalProvider>();
                          final txProv = context.read<TransactionProvider>();

                          await goalProv.deposit(goal.id, val);

                          if (goal.isSyncedWithWallet) {
                            await txProv.addTransaction(
                              title: 'Nabung: ${goal.title}',
                              amount: val,
                              type: TransactionType.expense,
                              category: 'Tabungan',
                              date: DateTime.now(),
                              note: 'Alokasi ke Celengan Impian (${goal.title})',
                            );
                          }

                          nav.pop();
                          final updatedSaved = goal.savedAmount + val;
                          final isNowCompleted = updatedSaved >= goal.targetAmount;

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                isNowCompleted
                                    ? '🎉 SELAMAT! Impian "${goal.title}" berhasil tercapai 100%!'
                                    : goal.isSyncedWithWallet
                                        ? 'Setoran ${AppFormatters.formatCurrency(val)} berhasil! Saldo kas utama telah terpotong 🪙'
                                        : 'Setoran ${AppFormatters.formatCurrency(val)} berhasil dicatat (Mode Mandiri: Kas utama tidak berubah) 🪙',
                              ),
                              backgroundColor: isNowCompleted ? const Color(0xFF087F8C) : const Color(0xFF16A36A),
                            ),
                          );
                        },
                        child: const Text('Setor Tabungan Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWithdrawSheet(GoalModel goal) {
    final amountController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.remove_circle_outline_rounded, color: Colors.orange, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Tarik: ${goal.title}',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    Text(
                      'Saldo celengan saat ini: ${AppFormatters.formatCurrency(goal.savedAmount)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Nominal Penarikan (Rp)',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...[20000, 50000, 100000, 200000].where((p) => p <= goal.savedAmount).map((preset) {
                          return ActionChip(
                            label: Text('+${AppFormatters.formatCurrency(preset)}'),
                            onPressed: () {
                              final curr = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                              final nextVal = curr + preset;
                              if (nextVal <= goal.savedAmount) {
                                amountController.text = nextVal.toInt().toString();
                              } else {
                                amountController.text = goal.savedAmount.toInt().toString();
                              }
                            },
                          );
                        }),
                        if (goal.savedAmount > 0)
                          ActionChip(
                            avatar: const Icon(Icons.all_out_rounded, size: 14),
                            label: Text('Tarik Semua (${AppFormatters.formatCurrency(goal.savedAmount)})'),
                            onPressed: () {
                              amountController.text = goal.savedAmount.toInt().toString();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: goal.isSyncedWithWallet
                            ? const Color(0xFF087F8C).withValues(alpha: 0.1)
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: goal.isSyncedWithWallet
                              ? const Color(0xFF087F8C).withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            goal.isSyncedWithWallet ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                            size: 18,
                            color: goal.isSyncedWithWallet ? const Color(0xFF087F8C) : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              goal.isSyncedWithWallet
                                  ? 'Terhubung Kas Utama: Saldo ditarik akan langsung dikembalikan ke dompet kas Anda (Kategori: Tabungan).'
                                  : 'Celengan Mandiri: Penarikan ini hanya mengurangi catatan impian tanpa menambah saldo kas utama.',
                              style: TextStyle(
                                fontSize: 12,
                                color: goal.isSyncedWithWallet
                                    ? (isDark ? Colors.tealAccent.shade100 : const Color(0xFF087F8C))
                                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange.shade800,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final val = double.tryParse(amountController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
                          if (val <= 0) return;
                          if (val > goal.savedAmount) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nominal penarikan melebihi saldo celengan.')),
                            );
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(sheetCtx);
                          final goalProv = context.read<GoalProvider>();
                          final txProv = context.read<TransactionProvider>();

                          await goalProv.withdraw(goal.id, val);

                          if (goal.isSyncedWithWallet) {
                            await txProv.addTransaction(
                              title: 'Tarik Celengan: ${goal.title}',
                              amount: val,
                              type: TransactionType.income,
                              category: 'Tabungan',
                              date: DateTime.now(),
                              note: 'Penarikan dari Celengan Impian (${goal.title})',
                            );
                          }

                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                goal.isSyncedWithWallet
                                    ? 'Penarikan ${AppFormatters.formatCurrency(val)} berhasil! Saldo sebesar ${AppFormatters.formatCurrency(val)} telah dikembalikan ke Kas Utama Anda 💵'
                                    : 'Penarikan ${AppFormatters.formatCurrency(val)} berhasil dicatat (Mode Mandiri: Kas utama tidak berubah)',
                              ),
                              backgroundColor: const Color(0xFF087F8C),
                            ),
                          );
                        },
                        child: const Text('Tarik Saldo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteGoal(GoalModel goal) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32),
        title: const Text('Hapus Celengan Impian?'),
        content: Text('Apakah kamu yakin ingin menghapus celengan "${goal.title}"?'),
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
              await context.read<GoalProvider>().deleteGoal(goal.id);
              messenger.showSnackBar(
                SnackBar(content: Text('Celengan "${goal.title}" berhasil dihapus.')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(GoalProvider provider, bool isDark) {
    final totalTarget = provider.totalTargetAmount;
    final totalSaved = provider.totalSavedAmount;
    final progress = provider.overallProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087F8C), Color(0xFF16A6A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087F8C).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.savings_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Total Celengan Impian',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppFormatters.formatCurrency(totalSaved),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'dari target total ${AppFormatters.formatCurrency(totalTarget)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎯 ${provider.activeGoalsCount} Celengan Aktif',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                '🏆 ${provider.completedGoalsCount} Tercapai',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKasUtamaInfo(TransactionProvider txProv, bool isDark) {
    final balance = txProv.totalBalance;
    final isPositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF0F4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF087F8C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: Color(0xFF087F8C),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo Kas Utama',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Dompet aktif saat ini',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Text(
            AppFormatters.formatCurrency(balance),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF16A36A) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal, bool isDark) {
    final progress = goal.progress;
    final isDone = goal.isCompleted;
    final remainingDays = goal.remainingDays;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDone
              ? const Color(0xFF16A36A)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isDone ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isDone
                      ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))
                      : (isDark ? const Color(0xFF0F3D3E) : const Color(0xFFE6F5F5)),
                  child: Icon(
                    isDone ? Icons.check_circle_rounded : Icons.savings_rounded,
                    color: isDone ? const Color(0xFF16A36A) : const Color(0xFF087F8C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            onSelected: (val) {
                              if (val == 'edit') {
                                _showAddEditGoalSheet(editGoal: goal);
                              } else if (val == 'delete') {
                                _confirmDeleteGoal(goal);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              goal.category,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: goal.isSyncedWithWallet
                                  ? const Color(0xFF087F8C).withValues(alpha: 0.12)
                                  : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  goal.isSyncedWithWallet ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                                  size: 11,
                                  color: goal.isSyncedWithWallet ? const Color(0xFF087F8C) : Colors.grey,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  goal.isSyncedWithWallet ? 'Sinkron Kas' : 'Mandiri',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: goal.isSyncedWithWallet ? const Color(0xFF087F8C) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (remainingDays != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              remainingDays < 0
                                  ? 'Lewat ${-remainingDays} hari'
                                  : 'Sisa $remainingDays hari lagi',
                              style: TextStyle(
                                fontSize: 11,
                                color: remainingDays < 0 ? Colors.red : Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormatters.formatCurrency(goal.savedAmount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDone ? const Color(0xFF16A36A) : const Color(0xFF087F8C),
                  ),
                ),
                Text(
                  'Target: ${AppFormatters.formatCurrency(goal.targetAmount)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDone ? const Color(0xFF16A36A) : const Color(0xFF087F8C),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDone
                      ? '🎉 Target tercapai!'
                      : 'Kurang ${AppFormatters.formatCurrency(goal.remainingAmount)} lagi',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                    color: isDone ? const Color(0xFF16A36A) : Colors.grey,
                  ),
                ),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (goal.note != null && goal.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Catatan: ${goal.note}',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 16),
                    label: const Text('Tarik'),
                    onPressed: goal.savedAmount <= 0 ? null : () => _showWithdrawSheet(goal),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF087F8C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                    label: const Text('+ Tabung'),
                    onPressed: () => _showDepositSheet(goal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allGoals = goalProvider.goals;
    final displayedGoals = allGoals.where((g) {
      if (_filter == 'active') return !g.isCompleted;
      if (_filter == 'completed') return g.isCompleted;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Celengan Impian'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await goalProvider.loadGoals();
          await txProvider.loadTransactions();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildSummaryCard(goalProvider, isDark),
            const SizedBox(height: 10),
            _buildKasUtamaInfo(txProvider, isDark),
            const SizedBox(height: 20),

            // Header Daftar Impian dengan Filter Responsif Penuh (Tanpa Offset)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Impian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${displayedGoals.length} Impian',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Segmented filter full-width agar tidak pernah terpotong di tepi layar
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                segments: const [
                  ButtonSegment(value: 'all', label: Text('Semua')),
                  ButtonSegment(value: 'active', label: Text('Aktif')),
                  ButtonSegment(value: 'completed', label: Text('Selesai')),
                ],
                selected: {_filter},
                onSelectionChanged: (val) {
                  setState(() => _filter = val.first);
                },
              ),
            ),
            const SizedBox(height: 14),

            if (displayedGoals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 64,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _filter == 'completed'
                          ? 'Belum ada celengan yang selesai.'
                          : _filter == 'active'
                              ? 'Semua celengan sudah tercapai!'
                              : 'Belum ada celengan impian.',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Yuk buat target tabungan untuk barang atau impianmu!',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...displayedGoals.map((g) => _buildGoalCard(g, isDark)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF087F8C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Celengan'),
        onPressed: () => _showAddEditGoalSheet(),
      ),
    );
  }
}
