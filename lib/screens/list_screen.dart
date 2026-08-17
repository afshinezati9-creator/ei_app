import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../models/transaction.dart';

class ListScreen extends StatefulWidget {
  final String sectionTitle;
  final List<Transaction> items;
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
  String query = '';
  String sortBy = 'date-desc';

  List<Transaction> get filtered {
    var list = List<Transaction>.from(widget.items);

    if (query.isNotEmpty) {
      list = list.where((t) => t.title.contains(query)).toList();
    }

    list.sort((a, b) {
      switch (sortBy) {
        case 'date-desc':
          return b.date.compareTo(a.date);
        case 'date-asc':
          return a.date.compareTo(b.date);
        case 'amount-desc':
          return b.amount.compareTo(a.amount);
        case 'amount-asc':
          return a.amount.compareTo(b.amount);
        default:
          return 0;
      }
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final items = filtered;

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
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('موردی یافت نشد', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                final t = items[index];
                final sign = widget.isNegative ? '−' : '+';
                final color = widget.isNegative ? Colors.red.shade400 : Colors.green.shade400;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.date, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        if (t.extra != null && t.extra!.isNotEmpty)
                          Text(t.extra!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        if (t.note != null && t.note!.isNotEmpty)
                          Text(t.note!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic)),
                        if (widget.isGoal && t.target != null)
                          _buildProgress(t.amount, t.target!),
                      ],
                    ),
                    trailing: Text(
                      '$sign ${currency.formatNumber(t.amount)} ${currency.symbol}',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProgress(double current, double target) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          color: const Color(0xFF6C5CE7),
          minHeight: 6,
        ),
        const SizedBox(height: 2),
        Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('جستجو'),
        content: TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: const InputDecoration(hintText: 'عنوان...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('بستن')),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('مرتب‌سازی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _sortOption('جدیدترین', 'date-desc'),
            _sortOption('قدیمی‌ترین', 'date-asc'),
            _sortOption('بیشترین مبلغ', 'amount-desc'),
            _sortOption('کمترین مبلغ', 'amount-asc'),
          ],
        ),
      ),
    );
  }

  Widget _sortOption(String label, String value) => ListTile(
        title: Text(label),
        trailing: sortBy == value ? const Icon(Icons.check, color: Color(0xFF6C5CE7)) : null,
        onTap: () {
          setState(() => sortBy = value);
          Navigator.pop(context);
        },
      );
}