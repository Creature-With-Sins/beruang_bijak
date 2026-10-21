import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_formatters.dart';

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

  final Map<String, List<String>> _categories = {
    'Pemasukan': ['Gaji', 'Pemasukan', 'Bonus', 'Investasi'],
    'Pengeluaran': [
      'Makanan',
      'Transport',
      'Belanja',
      'Hiburan',
      'Kesehatan',
      'Pendidikan',
      'Tagihan',
      'Lainnya',
    ],
  };

  String get _typeLabel =>
      _type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';

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
    final categories = _categories[_typeLabel]!;
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F7FA),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                _isEditing ? 'Perbarui Transaksi' : 'Catat Keuanganmu',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isEditing
                    ? 'Ubah informasi transaksi di bawah ini.'
                    : 'Lengkapi informasi transaksi pemasukan atau pengeluaran.',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Jenis transaksi
              const Text(
                'Jenis Transaksi',
                style: TextStyle(fontWeight: FontWeight.w600),
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
                    _category = _categories[_typeLabel]!.first;
                  });
                },
              ),
              const SizedBox(height: 22),

              // Judul
              const Text(
                'Judul Transaksi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
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
              const Text(
                'Nominal (Rp)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(
                  hint: 'Contoh: 25000',
                  icon: Icons.payments_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi.';
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
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey('${_type}_$_category'),
                initialValue: _category,
                decoration: _inputDecoration(
                  hint: 'Pilih kategori',
                  icon: Icons.category_outlined,
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
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
                        const Text(
                          'Tanggal Transaksi',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              hint: 'Pilih tanggal',
                              icon: Icons.calendar_month_rounded,
                            ),
                            child: Text(
                              AppFormatters.formatFullDate(_date),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                        const Text(
                          'Waktu',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              hint: 'Jam',
                              icon: Icons.access_time_rounded,
                            ),
                            child: Text(
                              AppFormatters.formatTime(_date),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF087F8C),
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
              const Text(
                'Catatan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
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
                    backgroundColor: const Color(0xFF087F8C),
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF087F8C)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1E7ED)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1E7ED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF087F8C), width: 1.5),
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
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF087F8C),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFFE6F5F5),
      side: const BorderSide(color: Color(0xFFB5E4E0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }
}
