import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_formatters.dart';
import '../widgets/transaction_card.dart';

enum DateFilterPreset { all, today, thisWeek, thisMonth, custom }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  DateFilterPreset _selectedPreset = DateFilterPreset.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      helpText: 'Pilih rentang tanggal riwayat',
      saveText: 'Terapkan',
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPreset = DateFilterPreset.custom;
      });
    } else if (_startDate == null) {
      setState(() {
        _selectedPreset = DateFilterPreset.all;
      });
    }
  }

  void _applyPreset(DateFilterPreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (preset == DateFilterPreset.custom) {
      _selectDateRange();
      return;
    }

    setState(() {
      _selectedPreset = preset;
      switch (preset) {
        case DateFilterPreset.all:
          _startDate = null;
          _endDate = null;
          break;
        case DateFilterPreset.today:
          _startDate = today;
          _endDate = today;
          break;
        case DateFilterPreset.thisWeek:
          _startDate = today.subtract(const Duration(days: 6));
          _endDate = today;
          break;
        case DateFilterPreset.thisMonth:
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case DateFilterPreset.custom:
          break;
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
      _selectedPreset = DateFilterPreset.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;

    final categories = transactions
        .map((tx) => tx.category)
        .toSet()
        .toList()
      ..sort();

    // Pengaman: Jika kategori terpilih sudah tidak ada di list data, reset ke null
    if (_selectedCategory != null && !categories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }

    final filteredTransactions = transactions.where((tx) {
      final matchesSearch =
          tx.title.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == null || tx.category == _selectedCategory;

      final matchesStartDate = _startDate == null ||
          !tx.date.isBefore(
            DateTime(_startDate!.year, _startDate!.month, _startDate!.day),
          );

      final matchesEndDate = _endDate == null ||
          tx.date.isBefore(
            DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day + 1,
            ),
          );

      return matchesSearch &&
          matchesCategory &&
          matchesStartDate &&
          matchesEndDate;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Mengelompokkan transaksi per tanggal kalender untuk UX membaca yang rapi
    final Map<DateTime, List<TransactionModel>> groupedTransactions = {};
    for (final tx in filteredTransactions) {
      final dayKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groupedTransactions.putIfAbsent(dayKey, () => []).add(tx);
    }
    final sortedDayKeys = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final hasActiveFilter = _searchQuery.isNotEmpty ||
        _selectedCategory != null ||
        _selectedPreset != DateFilterPreset.all;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (hasActiveFilter)
            IconButton(
              tooltip: 'Reset filter',
              onPressed: _resetFilters,
              icon: Icon(
                Icons.filter_alt_off_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Column(
                children: [
                  // Search Box
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Cari judul transaksi...',
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF0F4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF0F4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Kategori Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF0F4),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        dropdownColor: theme.cardColor,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                        hint: Text(
                          'Semua kategori',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Semua kategori',
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ),
                          ...categories.map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Quick Date Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _DateFilterChip(
                          label: 'Semua',
                          isSelected: _selectedPreset == DateFilterPreset.all,
                          onTap: () => _applyPreset(DateFilterPreset.all),
                        ),
                        const SizedBox(width: 8),
                        _DateFilterChip(
                          label: 'Hari Ini',
                          isSelected: _selectedPreset == DateFilterPreset.today,
                          onTap: () => _applyPreset(DateFilterPreset.today),
                        ),
                        const SizedBox(width: 8),
                        _DateFilterChip(
                          label: '7 Hari Terakhir',
                          isSelected:
                              _selectedPreset == DateFilterPreset.thisWeek,
                          onTap: () => _applyPreset(DateFilterPreset.thisWeek),
                        ),
                        const SizedBox(width: 8),
                        _DateFilterChip(
                          label: 'Bulan Ini',
                          isSelected:
                              _selectedPreset == DateFilterPreset.thisMonth,
                          onTap: () => _applyPreset(DateFilterPreset.thisMonth),
                        ),
                        const SizedBox(width: 8),
                        _DateFilterChip(
                          label: _selectedPreset == DateFilterPreset.custom &&
                                  _startDate != null &&
                                  _endDate != null
                              ? '${AppFormatters.formatDate(_startDate!)} - ${AppFormatters.formatDate(_endDate!)}'
                              : 'Pilih Tanggal 📅',
                          isSelected:
                              _selectedPreset == DateFilterPreset.custom,
                          onTap: () => _applyPreset(DateFilterPreset.custom),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Header Total Transaksi Ditemukan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Daftar Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${filteredTransactions.length} transaksi',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Grouped Transaction List
            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Transaksi tidak ditemukan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Coba ubah kata kunci atau periode tanggal.',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: sortedDayKeys.length,
                      itemBuilder: (context, dayIndex) {
                        final dayKey = sortedDayKeys[dayIndex];
                        final dayTransactions = groupedTransactions[dayKey]!;

                        final dayExpense = dayTransactions
                            .where((t) => t.type == TransactionType.expense)
                            .fold<double>(0, (sum, t) => sum + t.amount);
                        final dayIncome = dayTransactions
                            .where((t) => t.type == TransactionType.income)
                            .fold<double>(0, (sum, t) => sum + t.amount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Day Group Header
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 8,
                                left: 4,
                                right: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppFormatters.formatDayHeader(dayKey),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (dayIncome > 0)
                                        Text(
                                          '+${AppFormatters.formatCurrency(dayIncome)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF16A36A),
                                          ),
                                        ),
                                      if (dayIncome > 0 && dayExpense > 0)
                                        const Text(
                                          ' • ',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      if (dayExpense > 0)
                                        Text(
                                          '-${AppFormatters.formatCurrency(dayExpense)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE05252),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Transactions for this day
                            ...dayTransactions.map(
                              (transaction) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TransactionCard(
                                  transaction: transaction,
                                  showDate: false,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFEDF0F4)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}