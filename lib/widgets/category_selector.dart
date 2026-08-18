import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/data_provider.dart';

class CategorySelector extends StatefulWidget {
  final String selectedCategoryId;
  final String selectedCategoryName;
  final String type;
  final bool isDark;
  final Function(String id, String name) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.selectedCategoryName,
    required this.type,
    required this.isDark,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final TextEditingController _newCategoryController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _addNewCategory() {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = '⚠️ نام دسته را وارد کنید');
      return;
    }

    final data = context.read<DataProvider>();
    final existing = data.categories.firstWhere(
      (c) => c.name == name && c.type == widget.type,
      orElse: () => Category(id: '', name: '', icon: '', type: '', color: ''),
    );

    if (existing.id.isNotEmpty) {
      setState(() => _errorMessage = '⚠️ این دسته قبلاً وجود دارد');
      return;
    }

    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: '📌',
      type: widget.type,
      color: '#6C5CE7',
    );

    data.addCategory(newCategory);
    _newCategoryController.clear();
    setState(() => _errorMessage = '');
    widget.onCategorySelected(newCategory.id, newCategory.name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ دسته "$name" اضافه شد')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final categories = data.getCategoriesByType(widget.type);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'دسته‌بندی *',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: categories.map((cat) {
              final isSelected = cat.id == widget.selectedCategoryId;
              return FilterChip(
                label: Text(
                  '${cat.icon} ${cat.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    widget.onCategorySelected(cat.id, cat.name);
                  }
                },
                selectedColor: const Color(0xFF6C5CE7),
                backgroundColor: widget.isDark ? const Color(0xFF1A1A2E) : Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF6C5CE7)
                      : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // ===== افزودن دسته جدید =====
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCategoryController,
                  decoration: InputDecoration(
                    hintText: 'دسته جدید...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() => _errorMessage = ''),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addNewCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text('➕', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}