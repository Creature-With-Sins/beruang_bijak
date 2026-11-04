import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_formatters.dart';
import 'manage_categories_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  late String _category;
  late DateTime _date;
  bool _isSaving = false;

  bool get _isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    final editTx = widget.transactionToEdit;
    if (editTx != null) {
      _titleController = TextEditingController(text: editTx.title);
      _amountController = TextEditingController(
        text: editTx.amount % 1 == 0
            ? editTx.amount.toInt().toString()
            : editTx.amount.toString(),
      );
      _noteController = TextEditingController(text: editTx.note ?? '');
      _type = editTx.type;
      _category = editTx.category;
      _date = editTx.date;
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _type = TransactionType.expense;
      _category = 'Makanan';
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addQuickAmount(int additional) {
    final current = double.tryParse(
          _amountController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    final total = current + additional;
    _amountController.text = total.toInt().toString();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih tanggal transaksi',
    );

    if (selected != null && mounted) {
      final now = DateTime.now();
      final hour = (_date.hour != 0 || _date.minute != 0) ? _date.hour : now.hour;
      final minute = (_date.hour != 0 || _date.minute != 0) ? _date.minute : now.minute;
      final second = _date.second != 0 ? _date.second : now.second;

      setState(() {
        _date = DateTime(
          selected.year,
          selected.month,
          selected.day,
          hour,
          minute,
          second,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
      helpText: 'Pilih jam transaksi',
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _date = DateTime(
          _date.year,
          _date.month,
          _date.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _showQuickAddCategoryDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Tambah Kategori ${_type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran'}'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama Kategori Baru',
            hintText: 'Misal: Sedekah, Kursus, Gadget',
            border: OutlineInputBorder(),
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
              final name = textController.text.trim();
              if (name.isEmpty) return;

              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(dialogCtx);
              final provider = context.read<CategoryProvider>();
              final success = await provider.addCategory(_type, name);

              nav.pop();
              if (!mounted) return;
              if (success) {
                setState(() => _category = name);
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
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = _amountController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final amount = double.tryParse(rawAmount);

    if (amount == null || !amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal yang valid dan lebih dari nol.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<TransactionProvider>();
      if (_isEditing) {
        await provider.updateTransaction(
          id: widget.transactionToEdit!.id,
          title: _titleController.text.trim(),
          amount: amount,
          type: _type,
          category: _category,
          date: _date,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
      } else {
        await provider.addTransaction(
          title: _titleController.text.trim(),
          amount: amount,
          type: _type,
          category: _category,
          date: _date,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Transaksi berhasil diperbarui.'
                : 'Transaksi berhasil disimpan.',
          ),
          backgroundColor: const Color(0xFF087F8C),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.getCategories(_type);

    if (!categories.contains(_category)) {
      _category = categories.isNotEmpty
          ? categories.first
          : (_type == TransactionType.income ? 'Gaji' : 'Makanan');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                _isEditing ? 'Perbarui Transaksi' : 'Catat Keuanganmu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isEditing
                    ? 'Ubah informasi transaksi di bawah ini.'
                    : 'Lengkapi informasi transaksi pemasukan atau pengeluaran.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),

              // Jenis transaksi
              Text(
                'Jenis Transaksi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.south_west_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.north_east_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                    final newCats = categoryProvider.getCategories(_type);
                    _category = newCats.isNotEmpty ? newCats.first : 'Lainnya';
                  });
                },
              ),
              const SizedBox(height: 22),

              // Judul
              Text(
                'Judul Transaksi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: _inputDecoration(
                  context,
                  hint: 'Contoh: Makan siang, Gaji bulanan, dsb.',
                  icon: Icons.edit_note_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul transaksi wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Nominal
              Text(
                'Nominal (Rp)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: _inputDecoration(
                  context,
                  hint: 'Contoh: 25000',
                  icon: Icons.payments_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi.';
                  }
                  final parsed = double.tryParse(
                    value.trim().replaceAll('.', '').replaceAll(',', '.'),
                  );
                  if (parsed == null || !parsed.isFinite || parsed <= 0) {
                    return 'Masukkan nominal angka yang valid dan lebih dari nol.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Quick Nominal Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickChip(label: '+10 rb', onTap: () => _addQuickAmount(10000)),
                  _QuickChip(label: '+20 rb', onTap: () => _addQuickAmount(20000)),
                  _QuickChip(label: '+50 rb', onTap: () => _addQuickAmount(50000)),
                  _QuickChip(label: '+100 rb', onTap: () => _addQuickAmount(100000)),
                  _QuickChip(label: '+500 rb', onTap: () => _addQuickAmount(500000)),
                ],
              ),
              const SizedBox(height: 20),

              // Kategori
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kategori',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                        label: const Text('Tambah', style: TextStyle(fontSize: 12)),
                        onPressed: () => _showQuickAddCategoryDialog(context),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        icon: const Icon(Icons.settings_outlined, size: 15),
                        label: const Text('Kelola', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageCategoriesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey('${_type}_$_category'),
                initialValue: _category,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                decoration: _inputDecoration(
                  context,
                  hint: 'Pilih kategori',
                  icon: Icons.category_outlined,
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Tanggal
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Transaksi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              context,
                              hint: 'Pilih tanggal',
                              icon: Icons.calendar_month_rounded,
                            ),
                            child: Text(
                              AppFormatters.formatFullDate(_date),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waktu',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              context,
                              hint: 'Jam',
                              icon: Icons.access_time_rounded,
                            ),
                            child: Text(
                              AppFormatters.formatTime(_date),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Catatan opsional
              Text(
                'Catatan (Opsional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: _inputDecoration(
                  context,
                  hint: 'Tambahkan catatan jika diperlukan',
                  icon: Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveTransaction,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isEditing ? Icons.check_rounded : Icons.save_rounded,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Menyimpan...'
                        : (_isEditing ? 'Perbarui Transaksi' : 'Simpan Transaksi'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE1E7ED),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE1E7ED),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF087F8C),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isDark
          ? const Color(0xFF134E4A).withValues(alpha: 0.35)
          : const Color(0xFFE6F5F5),
      side: BorderSide(
        color: isDark ? const Color(0xFF0F766E) : const Color(0xFFB5E4E0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }
}
