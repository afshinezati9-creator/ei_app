// ============================================================
// مسیر: lib/screens/add_goal_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/date_provider.dart';
import '../utils/date_helpers.dart';
import 'package:ei_app/providers/providers.dart';

// ===== TextInputFormatter برای فرمت خودکار تاریخ شمسی =====
class _ShamsiDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return const TextEditingValue(text: '');

    String formatted = '';
    for (int i = 0; i < text.length && i < 8; i++) {
      if (i == 4 || i == 6) {
        formatted += '/';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ===== TextInputFormatter برای فرمت اعداد با کاما =====
class _CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return const TextEditingValue(text: '');

    final number = int.tryParse(text) ?? 0;
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddGoalScreen extends StatefulWidget {
  final Goal? goal;

  const AddGoalScreen({super.key, this.goal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _noteController = TextEditingController();

  GoalPriority _selectedPriority = GoalPriority.medium;
  String _selectedColor = '#6C5CE7';
  bool _isEditing = false;

  final List<String> _colors = [
    '#6C5CE7', '#0984E3', '#00B894', '#FDCB6E',
    '#E84393', '#FF6B6B', '#F39C12', '#636E72',
  ];

  final List<Map<String, dynamic>> _priorityOptions = [
    {'value': GoalPriority.low, 'label': 'کم', 'color': Colors.green},
    {'value': GoalPriority.medium, 'label': 'متوسط', 'color': Colors.orange},
    {'value': GoalPriority.high, 'label': 'بالا', 'color': Colors.red},
  ];

  String _titleError = '';
  String _targetError = '';
  String _deadlineError = '';

  @override
  void initState() {
    super.initState();
    _isEditing = widget.goal != null;

    if (widget.goal != null) {
      final g = widget.goal!;
      _titleController.text = g.title;
      _descriptionController.text = g.description;
      _targetController.text = g.targetAmount.toInt().toString();
      _deadlineController.text = g.deadline;
      _noteController.text = g.note ?? '';
      _selectedPriority = g.priority;
      _selectedColor = g.color;
    } else {
      final dateProvider = context.read<DateProvider>();
      _deadlineController.text = dateProvider.getToday();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _deadlineController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    // اعتبارسنجی عنوان
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '⚠️ عنوان هدف را وارد کنید');
      return;
    } else {
      setState(() => _titleError = '');
    }

    // اعتبارسنجی مبلغ هدف
    final targetStr = _targetController.text.replaceAll(RegExp(r'[^\d]'), '');
    final target = double.tryParse(targetStr) ?? 0;
    if (target <= 0) {
      setState(() => _targetError = '⚠️ مبلغ هدف را به درستی وارد کنید');
      return;
    } else {
      setState(() => _targetError = '');
    }

    // اعتبارسنجی تاریخ سررسید
    final deadline = _deadlineController.text.trim();
    if (!DateProvider.isValidShamsiDate(deadline)) {
      setState(() => _deadlineError = '⚠️ فرمت تاریخ اشتباه است (۱۴۰۴/۰۵/۲۰)');
      return;
    } else {
      setState(() => _deadlineError = '');
    }

    final dateProvider = context.read<DateProvider>();
    final today = dateProvider.getToday();

    final goal = Goal(
      id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      targetAmount: target,
      currentAmount: widget.goal?.currentAmount ?? 0,
      deadline: deadline,
      priority: _selectedPriority,
      status: widget.goal?.status ?? GoalStatus.inProgress,
      color: _selectedColor,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      createdAt: widget.goal?.createdAt ?? today,
    );

    final data = context.read<DataProvider>();
    if (_isEditing) {
      data.updateGoal(goal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ هدف ویرایش شد')),
      );
    } else {
      data.addGoal(goal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ هدف اضافه شد')),
      );
    }

    Navigator.pop(context, true);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف هدف'),
        content: const Text('آیا از حذف این هدف مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final data = context.read<DataProvider>();
              data.deleteGoal(widget.goal!.id);
              Navigator.pop(ctx);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ هدف حذف شد')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش هدف' : 'هدف جدید'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== عنوان =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان هدف *',
                    hintText: 'مثلاً خرید لپ‌تاپ',
                    border: InputBorder.none,
                    errorText: _titleError.isNotEmpty ? _titleError : null,
                  ),
                  onChanged: (_) => setState(() => _titleError = ''),
                ),
              ),
              const SizedBox(height: 12),

              // ===== مبلغ هدف و تاریخ سررسید =====
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _targetController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'مبلغ هدف *',
                          hintText: '۰',
                          border: InputBorder.none,
                          errorText: _targetError.isNotEmpty ? _targetError : null,
                        ),
                        onChanged: (_) => setState(() => _targetError = ''),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _deadlineController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          _ShamsiDateFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'تاریخ سررسید *',
                          hintText: '۱۴۰۴/۰۵/۲۰',
                          border: InputBorder.none,
                          errorText: _deadlineError.isNotEmpty ? _deadlineError : null,
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() => _deadlineError = ''),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== اولویت =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                      'اولویت',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: _priorityOptions.map((option) {
                        final isSelected = _selectedPriority == option['value'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(option['label']),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedPriority = option['value'];
                                });
                              }
                            },
                            selectedColor: option['color'],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== انتخاب رنگ =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                      'رنگ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: _colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedColor = color);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _hexToColor(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6C5CE7)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== توضیحات =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات (اختیاری)',
                    hintText: 'توضیحات بیشتر درباره هدف...',
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ===== یادداشت =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'یادداشت (اختیاری)',
                    hintText: 'یادداشت اضافی...',
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== دکمه ذخیره =====
              ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEditing ? 'ویرایش هدف' : 'افزودن هدف',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}