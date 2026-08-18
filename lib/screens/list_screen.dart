import '../models/account.dart';
import '../models/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/data_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/date_provider.dart'; // اضافه شده
import '../widgets/pagination.dart';
import '../widgets/filter_chips.dart';
import '../utils/formatters.dart';
import 'add_transaction_screen.dart';
import 'package:ei_app/providers/providers.dart';

class ListScreen extends StatefulWidget {
  final String sectionTitle;
  final List<TransactionModel> items;
  final bool isNegative;
  final bool isGoal;

  const ListScreen({
    super.key,
    required this.sectionTitle,
    required this.items,
    this.isNegative = false,
    this.isGoal = false,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String _searchQuery = '';
  String _filterAccount = '';
  String _filterCategory = '';
  int _currentPage = 1;
  int _pageSize = 10;

  List<TransactionModel> get _filteredItems {
    var list = List<TransactionModel>.from(widget.items);

    // جستجو
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((t) =>
        t.title.toLowerCase().contains(query) ||
        (t.contact?.toLowerCase().contains(query) ?? false) ||
        t.categoryName.toLowerCase().contains(query)
      ).toList();
    }

    // فیلتر حساب
    if (_filterAccount.isNotEmpty) {
      list = list.where((t) => t.paymentMethod == _filterAccount).toList();
    }

    // فیلتر دسته‌بندی
    if (_filterCategory.isNotEmpty) {
      list = list.where((t) => t.categoryId == _filterCategory).toList();
    }

    // مرتب‌سازی بر اساس تاریخ (جدیدترین)
    list.sort((a, b) => b.date.compareTo(a.date));

    return list;
  }

  List<TransactionModel> get _pageItems {
    final total = _filteredItems.length;
    final totalPages = (total / _pageSize).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;

    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    return _filteredItems.sublist(
      start,
      end > total ? total : end,
    );
  }

  int get _totalPages {
    return (_filteredItems.length / _pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currency = context.watch<CurrencyProvider>();
    final theme = context.watch<ThemeProvider>();
    final dateProvider = context.watch<DateProvider>(); // اضافه شده
    final isDark = theme.isDarkMode(context);
    final pageItems = _pageItems;

    // حساب‌ها برای فیلتر
    final accounts = data.accounts;

    // دسته‌بندی‌ها برای فیلتر
    final categories = data.getCategoriesByType(
      widget.isNegative ? 'expense' : 'income',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(accounts, categories),
          ),
        ],
      ),
      body: Column(
        children: [
          // نمایش فیلترهای فعال
          if (_filterAccount.isNotEmpty || _filterCategory.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (_filterAccount.isNotEmpty)
                    _buildFilterChip(
                      label: 'حساب: ${_getAccountName(_filterAccount, accounts)}',
                      onRemove: () => setState(() => _filterAccount = ''),
                    ),
                  if (_filterCategory.isNotEmpty)
                    _buildFilterChip(
                      label: 'دسته: ${_getCategoryName(_filterCategory, categories)}',
                      onRemove: () => setState(() => _filterCategory = ''),
                    ),
                  if (_filterAccount.isNotEmpty || _filterCategory.isNotEmpty)
                    _buildFilterChip(
                      label: 'پاک کردن همه',
                      onRemove: () => setState(() {
                        _filterAccount = '';
                        _filterCategory = '';
                      }),
                      isClear: true,
                    ),
                ],
              ),
            ),

          // لیست آیتم‌ها
          Expanded(
            child: pageItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'موردی یافت نشد',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: pageItems.length,
                    itemBuilder: (ctx, index) {
                      final t = pageItems[index];
                      return _buildTransactionItem(t, currency, dateProvider, isDark);
                    },
                  ),
          ),

          // صفحه‌بندی
          if (_filteredItems.length > _pageSize)
            Pagination(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    bool isClear = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isClear ? Colors.red.shade100 : const Color(0xFF6C5CE7).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isClear ? Colors.red.shade300 : const Color(0xFF6C5CE7).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isClear ? Colors.red.shade700 : const Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: isClear ? Colors.red.shade700 : const Color(0xFF6C5CE7),
            ),
          ),
        ],
      ),
    );
  }

  String _getAccountName(String id, List<dynamic> accounts) {
    final acc = accounts.cast<Account>().firstWhere(
      (a) => a.id == id,
      orElse: () => Account(
        id: '',
        name: 'نامشخص',
        type: 'cash',
        number: '',
        holder: '',
      ),
    );
    return acc.name;
  }

  String _getCategoryName(String id, List<dynamic> categories) {
    final cat = categories.cast<Category>().firstWhere(
      (c) => c.id == id,
      orElse: () => Category(
        id: '',
        name: 'نامشخص',
        icon: '📌',
        type: 'expense',
        color: '#636E72',
      ),
    );
    return cat.name;
  }

  // _buildTransactionItem با dateProvider و تبدیل تاریخ
  Widget _buildTransactionItem(
    TransactionModel t,
    CurrencyProvider currency,
    DateProvider dateProvider, // اضافه شده
    bool isDark,
  ) {
    final isNeg = widget.isNegative;
    final sign = isNeg ? '−' : '+';
    final color = isNeg ? Colors.red.shade400 : Colors.green.shade400;

    // تبدیل تاریخ به فرمت انتخابی
    final displayDate = dateProvider.convertDate(t.date, dateProvider.currentFormat);

    return GestureDetector(
      onTap: () {
        // رفتن به صفحه ویرایش
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(transaction: t),
          ),
        ).then((_) {
          // بعد از بازگشت، داده‌ها به‌روز می‌شن
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isNeg ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    // استفاده از تاریخ تبدیل‌شده
                    '$displayDate ${t.time.isNotEmpty ? t.time : ''} · ${t.categoryName}${t.contact != null && t.contact!.isNotEmpty ? ' · ${t.contact}' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                  if (widget.isGoal && t.target != null)
                    _buildGoalProgress(t.amount, t.target!),
                ],
              ),
            ),
            Text(
              '$sign ${currency.formatNumber(t.amount)} ${currency.symbol}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(double current, double target) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            color: const Color(0xFF6C5CE7),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('جستجو'),
        content: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'عنوان، طرف حساب، دسته‌بندی...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(ctx);
            },
            child: const Text('پاک کردن'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(List<Account> accounts, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'فیلترها',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            // فیلتر حساب
            FilterChips(
              label: 'فیلتر بر اساس حساب',
              options: [
                'همه',
                ...accounts.map((a) => a.name),
              ],
              selected: _filterAccount.isEmpty
                  ? 'همه'
                  : (_getAccountName(_filterAccount, accounts) ?? 'همه'),
              onSelected: (value) {
                if (value == 'همه') {
                  setState(() => _filterAccount = '');
                } else {
                  final acc = accounts.firstWhere((a) => a.name == value);
                  setState(() => _filterAccount = acc.id);
                }
              },
            ),
            const SizedBox(height: 12),
            // فیلتر دسته‌بندی
            FilterChips(
              label: 'فیلتر بر اساس دسته‌بندی',
              options: [
                'همه',
                ...categories.map((c) => c.name),
              ],
              selected: _filterCategory.isEmpty
                  ? 'همه'
                  : (_getCategoryName(_filterCategory, categories) ?? 'همه'),
              onSelected: (value) {
                if (value == 'همه') {
                  setState(() => _filterCategory = '');
                } else {
                  final cat = categories.firstWhere((c) => c.name == value);
                  setState(() => _filterCategory = cat.id);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filterAccount = '';
                        _filterCategory = '';
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('پاک کردن همه'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('اعمال'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}