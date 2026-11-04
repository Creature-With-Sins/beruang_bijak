import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../utils/app_formatters.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String _filter = 'all'; // 'all', 'active', 'completed'

  void _showAddEditGoalDialog({GoalModel? editGoal}) {
    final titleController = TextEditingController(text: editGoal?.title ?? '');
    final targetController = TextEditingController(
      text: editGoal != null
          ? (editGoal.targetAmount % 1 == 0
              ? editGoal.targetAmount.toInt().toString()
              : editGoal.targetAmount.toString())
          : '',
    );
    final initialController = TextEditingController(
      text: editGoal != null
          ? (editGoal.savedAmount % 1 == 0
              ? editGoal.savedAmount.toInt().toString()
              : editGoal.savedAmount.toString())
          : '',
    );
    final noteController = TextEditingController(text: editGoal?.note ?? '');
    DateTime? selectedDate = editGoal?.targetDate;
    String selectedCategory = editGoal?.category ?? 'Elektronik';

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

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final isEditing = editGoal != null;

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.savings_rounded, color: Color(0xFF087F8C)),
                  const SizedBox(width: 8),
                  Text(isEditing ? 'Edit Celengan' : 'Celengan Impian Baru'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Nama Impian',
                        hintText: 'Misal: Beli Laptop Baru',
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
                    TextField(
                      controller: initialController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isEditing ? 'Jumlah Terkumpul Saat Ini (Rp)' : 'Setoran Awal (Opsional)',
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
                          setDialogState(() => selectedCategory = val);
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
                          setDialogState(() => selectedDate = picked);
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF087F8C)),
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
                    final nav = Navigator.of(dialogCtx);
                    final provider = context.read<GoalProvider>();
                    if (isEditing) {
                      final updated = editGoal.copyWith(
                        title: title,
                        targetAmount: target,
                        savedAmount: saved,
                        category: selectedCategory,
                        targetDate: selectedDate,
                        note: noteController.text.trim(),
                      );
                      await provider.updateGoal(updated);
                    } else {
                      await provider.addGoal(
                        title: title,
                        targetAmount: target,
                        initialAmount: saved,
                        category: selectedCategory,
                        targetDate: selectedDate,
                        note: noteController.text.trim(),
                      );
                    }

                    nav.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Celengan berhasil diperbarui!' : 'Celengan impian berhasil dibuat! 🎯'),
                        backgroundColor: const Color(0xFF087F8C),
                      ),
                    );
                  },
                  child: Text(isEditing ? 'Simpan' : 'Mulai Menabung'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDepositDialog(GoalModel goal) {
    final amountController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF16A36A), size: 36),
        title: Text('Nabung untuk "${goal.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terkumpul saat ini: ${AppFormatters.formatCurrency(goal.savedAmount)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Jumlah Setoran (Rp)',
                hintText: 'Misal: 50000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [20000, 50000, 100000, 200000].map((preset) {
                return ActionChip(
                  label: Text('+${AppFormatters.formatCurrency(preset)}'),
                  onPressed: () {
                    final curr = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                    amountController.text = (curr + preset).toInt().toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A36A)),
            onPressed: () async {
              final val = double.tryParse(amountController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
              if (val <= 0) return;

              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(dialogCtx);
              await context.read<GoalProvider>().deposit(goal.id, val);
              nav.pop();
              final updatedSaved = goal.savedAmount + val;
              final isNowCompleted = updatedSaved >= goal.targetAmount;

              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    isNowCompleted
                        ? '🎉 SELAMAT! Impian "${goal.title}" berhasil tercapai 100%!'
                        : 'Setoran ${AppFormatters.formatCurrency(val)} berhasil ditambahkan! 🪙',
                  ),
                  backgroundColor: isNowCompleted ? const Color(0xFF087F8C) : const Color(0xFF16A36A),
                ),
              );
            },
            child: const Text('Setor'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(GoalModel goal) {
    final amountController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.orange, size: 36),
        title: Text('Tarik Celengan "${goal.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo celengan saat ini: ${AppFormatters.formatCurrency(goal.savedAmount)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Jumlah Penarikan (Rp)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
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
              final nav = Navigator.of(dialogCtx);
              await context.read<GoalProvider>().withdraw(goal.id, val);
              nav.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Penarikan ${AppFormatters.formatCurrency(val)} berhasil dilakukan.'),
                ),
              );
            },
            child: const Text('Tarik Saldo'),
          ),
        ],
      ),
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
                                _showAddEditGoalDialog(editGoal: goal);
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
                    onPressed: goal.savedAmount <= 0 ? null : () => _showWithdrawDialog(goal),
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
                    onPressed: () => _showDepositDialog(goal),
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
        onRefresh: () => goalProvider.loadGoals(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildSummaryCard(goalProvider, isDark),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Impian',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SegmentedButton<String>(
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
              ],
            ),
            const SizedBox(height: 12),
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
        onPressed: () => _showAddEditGoalDialog(),
      ),
    );
  }
}

