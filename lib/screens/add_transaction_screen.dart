import '../models/transaction.dart'; // این خط باید بالای فایل باشه
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/data_provider.dart';
import '../providers/currency_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _extraController = TextEditingController();
  final _noteController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedType = 'expense';
  String? _selectedCategory;
  String? _selectedSubCategory;

  final List<Map<String, dynamic>> _types = [
    {'value': 'expense', 'label': 'مخارج', 'icon': Icons.arrow_downward, 'color': Colors.red},
    {'value': 'income', 'label': 'درآمد', 'icon': Icons.arrow_upward, 'color': Colors.green},
    {'value': 'saving', 'label': 'پس‌انداز', 'icon': Icons.savings, 'color': Colors.blue},
    {'value': 'goal', 'label': 'هدف', 'icon': Icons.flag, 'color': Colors.orange},
    {'value': 'loan', 'label': 'وام', 'icon': Icons.account_balance, 'color': Colors.purple},
    {'value': 'debt', 'label': 'قرض', 'icon': Icons.money_off, 'color': Colors.deepOrange},
    {'value': 'credit', 'label': 'طلبکاری', 'icon': Icons.payment, 'color': Colors.teal},
  ];

  final Map<String, List<String>> _categories = {
    'خوراک': ['نان', 'میوه', 'سبزیجات', 'گوشت', 'لبنیات', 'نوشیدنی', 'رستوران', 'فست‌فود'],
    'مسکن': ['اجاره', 'قبض برق', 'قبض آب', 'قبض گاز', 'تلفن', 'اینترنت', 'شارژ ساختمان'],
    'حمل و نقل': ['بنزین', 'تعمیرات', 'بلیط', 'کرایه تاکسی', 'سرویس مدارس'],
    'پوشاک': ['لباس', 'کفش', 'اکسسوری'],
    'بهداشت': ['دارو', 'دکتر', 'بیمه', 'لوازم بهداشتی'],
    'تفریح': ['سینما', 'رستوران', 'کافه', 'بازی', 'سفر'],
    'آموزش': ['شهریه', 'کتاب', 'کلاس', 'دوره آنلاین'],
    'سرمایه‌گذاری': ['صندوق', 'سهام', 'ارز', 'طلا'],
    'متفرقه': ['هدیه', 'کمک', 'متفرقه'],
  };

  final Map<String, List<String>> _incomeCategories = {
    'حقوق': ['پایه', 'پاداش', 'اضافه کار'],
    'پروژه': ['برنامه‌نویسی', 'طراحی', 'مشاوره', 'ترجمه'],
    'سود': ['سود بانکی', 'سود سهام', 'سود صندوق'],
    'اجاره': ['مسکونی', 'تجاری'],
    'هدیه': ['تولد', 'مناسبتی'],
    'متفرقه': ['متفرقه'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final t = widget.existingTransaction!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toString();
      _dateController.text = t.date;
      _selectedType = t.type;
      _extraController.text = t.extra ?? '';
      _noteController.text = t.note ?? '';
      _targetController.text = t.target?.toString() ?? '';
    } else {
      _dateController.text = '۱۴۰۴/۰۵/۲۰';
      _timeController.text = '۱۲:۰۰';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _extraController.dispose();
    _noteController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  bool get _isGoal => _selectedType == 'goal';
  bool get _isIncomeType => _selectedType == 'income' || _selectedType == 'credit';
  Map<String, List<String>> get _currentCategories =>
      _isIncomeType ? _incomeCategories : _categories;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مبلغ را به درستی وارد کنید')),
      );
      return;
    }

    final target = double.tryParse(_targetController.text);
    final category = _selectedCategory ?? 'متفرقه';
    final subCategory = _selectedSubCategory ?? '';

    final transaction = Transaction(
      id: widget.existingTransaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: amount,
      date: _dateController.text.trim(),
      type: _selectedType,
      extra: _selectedCategory != null
          ? '$_selectedCategory${subCategory.isNotEmpty ? ' · $subCategory' : ''}'
          : (_extraController.text.trim().isNotEmpty
              ? _extraController.text.trim()
              : null),
      note: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
      target: target,
    );

    final dataProvider = context.read<DataProvider>();
    if (widget.existingTransaction != null) {
      dataProvider.updateTransaction(transaction);
    } else {
      dataProvider.addTransaction(transaction);
    }

    Navigator.pop(context, true);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف تراکنش'),
        content: const Text('آیا از حذف این تراکنش مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          TextButton(
            onPressed: () {
              final dataProvider = context.read<DataProvider>();
              dataProvider.deleteTransaction(widget.existingTransaction!.id);
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = context.watch<CurrencyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTransaction != null ? 'ویرایش تراکنش' : 'افزودن تراکنش'),
        actions: [
          if (widget.existingTransaction != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== نوع تراکنش =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع تراکنش *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _types.map((type) {
                        final isSelected = _selectedType == type['value'];
                        return FilterChip(
                          label: Text(type['label']),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type['value'];
                                _selectedCategory = null;
                                _selectedSubCategory = null;
                              });
                            }
                          },
                          avatar: Icon(
                            type['icon'],
                            size: 16,
                            color: isSelected ? Colors.white : type['color'],
                          ),
                          selectedColor: type['color'],
                          labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ===== عنوان =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان *',
                    hintText: 'مثلاً خرید نان، حقوق، ...',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'لطفاً عنوان را وارد کنید';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ===== مبلغ و تاریخ =====
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'مبلغ (${currency.symbol}) *',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً مبلغ را وارد کنید';
                          }
                          if (double.tryParse(value) == null) {
                            return 'مبلغ را به عدد وارد کنید';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'تاریخ (مثال: ۱۴۰۴/۰۵/۲۰) *',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً تاریخ را وارد کنید';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== ساعت =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'ساعت (اختیاری)',
                    hintText: 'مثلاً ۱۲:۰۰',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== انتخاب دسته‌بندی =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isIncomeType ? 'دسته‌بندی درآمد' : 'دسته‌بندی مخارج',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _currentCategories.keys.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategory = cat;
                                _selectedSubCategory = null;
                              } else {
                                _selectedCategory = null;
                              }
                            });
                          },
                          selectedColor: const Color(0xFF6C5CE7),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                    if (_selectedCategory != null &&
                        _currentCategories[_selectedCategory] != null &&
                        _currentCategories[_selectedCategory]!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'زیردسته',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _currentCategories[_selectedCategory]!.map((sub) {
                          final isSelected = _selectedSubCategory == sub;
                          return ChoiceChip(
                            label: Text(sub),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSubCategory = selected ? sub : null;
                              });
                            },
                            selectedColor: const Color(0xFF6C5CE7).withOpacity(0.7),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ===== طرف حساب (اختیاری) =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _extraController,
                  decoration: const InputDecoration(
                    labelText: 'طرف حساب (اختیاری)',
                    hintText: 'مثلاً نانوایی، شرکت، بانک، ...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== مبلغ هدف (برای اهداف) =====
              if (_isGoal)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'مبلغ هدف (${currency.symbol}) *',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (_isGoal) {
                        if (value == null || value.trim().isEmpty) {
                          return 'لطفاً مبلغ هدف را وارد کنید';
                        }
                        if (double.tryParse(value) == null) {
                          return 'مبلغ را به عدد وارد کنید';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              if (_isGoal) const SizedBox(height: 16),

              // ===== یادداشت =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'یادداشت (اختیاری)',
                    hintText: 'توضیحات بیشتر...',
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===== دکمه ذخیره =====
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.existingTransaction != null ? 'ویرایش' : 'افزودن',
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