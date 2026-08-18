import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/account.dart';
import '../providers/data_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/date_provider.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../utils/date_helpers.dart';
import '../widgets/category_selector.dart';
import 'package:ei_app/providers/providers.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _contactController = TextEditingController();
  final _noteController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedCategoryId = '';
  String _selectedCategoryName = '';
  String _selectedAccountId = 'cash';
  String _selectedPriority = 'medium';
  String _selectedRecurrence = 'once';
  int _selectedReminder = 0;

  bool _isEditing = false;
  bool _showReminder = false;

  final List<Map<String, dynamic>> _types = [
    {'value': 'expense', 'label': 'مخارج', 'icon': Icons.arrow_downward, 'color': Colors.red},
    {'value': 'income', 'label': 'درآمد', 'icon': Icons.arrow_upward, 'color': Colors.green},
    {'value': 'saving', 'label': 'پس‌انداز', 'icon': Icons.savings, 'color': Colors.blue},
    {'value': 'goal', 'label': 'هدف', 'icon': Icons.flag, 'color': Colors.orange},
    {'value': 'loan', 'label': 'وام', 'icon': Icons.account_balance, 'color': Colors.purple},
    {'value': 'debt', 'label': 'قرض', 'icon': Icons.money_off, 'color': Colors.deepOrange},
    {'value': 'credit', 'label': 'طلبکاری', 'icon': Icons.payment, 'color': Colors.teal},
  ];

  final List<String> _priorities = ['low', 'medium', 'high'];
  final List<String> _recurrences = ['once', 'monthly', 'yearly'];
  final List<int> _reminders = [0, 1, 2, 6, 12, 24, 48];

  String _titleError = '';
  String _amountError = '';
  String _dateError = '';
  String _timeError = '';
  String _targetError = '';

  bool _isAmountFormatting = false;
  bool _isTargetFormatting = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;

    final dateProvider = context.read<DateProvider>();
    final today = dateProvider.getToday();

    if (widget.transaction != null) {
      final t = widget.transaction!;
      _titleController.text = t.title;
      _amountController.text = Formatters.formatNumber(t.amount);
      _dateController.text = t.date;
      _timeController.text = t.time.isNotEmpty ? t.time : DateHelpers.getCurrentTime();
      _selectedType = t.type;
      _selectedCategoryId = t.categoryId;
      _selectedCategoryName = t.categoryName;
      _selectedAccountId = t.paymentMethod;
      _contactController.text = t.contact ?? '';
      _noteController.text = t.note ?? '';
      _selectedPriority = t.priority ?? 'medium';
      _selectedRecurrence = t.recurrence ?? 'once';
      _targetController.text = t.target?.toString() ?? '';
      _showReminder = ['loan', 'debt', 'credit'].contains(t.type);
    } else {
      _dateController.text = today;
      _timeController.text = DateHelpers.getCurrentTime();
      _selectedCategoryId = _getDefaultCategory('expense');
    }
  }

  String _getDefaultCategory(String type) {
    final data = context.read<DataProvider>();
    final cats = data.getCategoriesByType(type);
    return cats.isNotEmpty ? cats.first.id : '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _contactController.dispose();
    _noteController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  bool get _isGoal => _selectedType == 'goal';
  bool get _showReminderFields => ['loan', 'debt', 'credit'].contains(_selectedType);

  // تبدیل اعداد فارسی به انگلیسی
  String _toEnglishDigits(String text) {
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    const english = '0123456789';
    return text.split('').map((char) {
      final index = persian.indexOf(char);
      return index != -1 ? english[index] : char;
    }).join('');
  }

  // تبدیل اعداد انگلیسی به فارسی
  String _toPersianDigits(String number) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    return number.split('').map((char) {
      final index = english.indexOf(char);
      return index != -1 ? persian[index] : char;
    }).join('');
  }

  // ===== اصلاح شده: ورود مبلغ با پشتیبانی از اعداد چندرقمی =====
  void _onAmountChanged(String value) {
    if (_isAmountFormatting) return;
    _isAmountFormatting = true;

    // تبدیل اعداد فارسی به انگلیسی
    final englishValue = _toEnglishDigits(value);
    final cleaned = englishValue.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.isEmpty) {
      _amountController.text = '';
      _isAmountFormatting = false;
      setState(() => _amountError = '');
      return;
    }

    final number = int.tryParse(cleaned);
    if (number != null) {
      final formatter = NumberFormat.decimalPattern('en_US');
      final formatted = formatter.format(number);
      final persianFormatted = _toPersianDigits(formatted);
      _amountController.text = persianFormatted;
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }

    _isAmountFormatting = false;
    setState(() => _amountError = '');
  }

  // ===== اصلاح شده: ورود ساعت با پشتیبانی از اعداد چندرقمی =====
  void _onTimeChanged(String value) {
    final englishValue = _toEnglishDigits(value);
    final cleaned = englishValue.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.isEmpty) {
      _timeController.text = '';
      setState(() => _timeError = '');
      return;
    }

    String formatted = '';
    for (int i = 0; i < cleaned.length && i < 4; i++) {
      if (i == 2) {
        formatted += ':';
      }
      formatted += cleaned[i];
    }

    // محدودیت ساعت و دقیقه
    if (formatted.length >= 2) {
      final hour = int.tryParse(formatted.substring(0, 2));
      if (hour != null && hour > 23) {
        formatted = '23${formatted.length > 2 ? formatted.substring(2) : ''}';
      }
    }
    if (formatted.length >= 5) {
      final minute = int.tryParse(formatted.substring(3, 5));
      if (minute != null && minute > 59) {
        formatted = formatted.substring(0, 3) + '59';
      }
    }

    _timeController.text = formatted;
    _timeController.selection = TextSelection.fromPosition(
      TextPosition(offset: _timeController.text.length),
    );

    if (formatted.length == 5) {
      setState(() => _timeError = '');
    }
  }

  void _validateAndSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '⚠️ عنوان را وارد کنید');
      return;
    } else {
      setState(() => _titleError = '');
    }

    // ===== اصلاح شده: تبدیل اعداد فارسی به انگلیسی قبل از اعتبارسنجی =====
    final amountStr = _toEnglishDigits(_amountController.text)
        .replaceAll(RegExp(r'[^\d]'), '');
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) {
      setState(() => _amountError = '⚠️ مبلغ را به درستی وارد کنید');
      return;
    } else {
      setState(() => _amountError = '');
    }

    final date = _dateController.text.trim();
    if (!DateProvider.isValidShamsiDate(date)) {
      setState(() => _dateError = '⚠️ فرمت تاریخ اشتباه است (۱۴۰۴/۰۵/۲۰)');
      return;
    } else {
      setState(() => _dateError = '');
    }

    final time = _timeController.text.trim();
    if (time.isNotEmpty && !Validators.isValidTime(time)) {
      setState(() => _timeError = '⚠️ فرمت زمان اشتباه است (۱۲:۰۰)');
      return;
    } else {
      setState(() => _timeError = '');
    }

    if (_isGoal) {
      final targetStr = _toEnglishDigits(_targetController.text)
          .replaceAll(RegExp(r'[^\d]'), '');
      final target = double.tryParse(targetStr) ?? 0;
      if (target <= 0) {
        setState(() => _targetError = '⚠️ مبلغ هدف را وارد کنید');
        return;
      } else {
        setState(() => _targetError = '');
      }
    }

    final transaction = TransactionModel(
      id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: date,
      time: time.isNotEmpty ? time : '۱۲:۰۰',
      type: _selectedType,
      categoryId: _selectedCategoryId,
      categoryName: _selectedCategoryName,
      paymentMethod: _selectedAccountId,
      contact: _contactController.text.trim().isNotEmpty ? _contactController.text.trim() : null,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      priority: _selectedPriority,
      recurrence: _selectedRecurrence,
      target: _isGoal ? double.tryParse(_targetController.text.replaceAll(RegExp(r'[^\d]'), '')) : null,
    );

    final data = context.read<DataProvider>();
    if (_isEditing) {
      data.updateTransaction(transaction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تراکنش ویرایش شد')),
      );
    } else {
      data.addTransaction(transaction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تراکنش اضافه شد')),
      );
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final data = context.read<DataProvider>();
              data.deleteTransaction(widget.transaction!.id);
              Navigator.pop(ctx);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ تراکنش حذف شد')),
              );
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
    final data = context.watch<DataProvider>();
    final currency = context.watch<CurrencyProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    final accounts = data.accounts;
    final categories = data.getCategoriesByType(_selectedType);

    if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
      _selectedCategoryName = categories.first.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش تراکنش' : 'افزودن تراکنش'),
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
              // ===== نوع تراکنش =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                      'نوع تراکنش *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _types.map((type) {
                        final isSelected = _selectedType == type['value'];
                        return FilterChip(
                          label: Text(type['label']),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type['value'];
                                final cats = data.getCategoriesByType(_selectedType);
                                if (cats.isNotEmpty) {
                                  _selectedCategoryId = cats.first.id;
                                  _selectedCategoryName = cats.first.name;
                                }
                                _showReminder = ['loan', 'debt', 'credit'].contains(_selectedType);
                              });
                            }
                          },
                          avatar: Icon(
                            type['icon'],
                            size: 14,
                            color: isSelected ? Colors.white : type['color'],
                          ),
                          selectedColor: type['color'],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== عنوان =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'عنوان *',
                        hintText: 'مثلاً خرید نان، حقوق، ...',
                        border: InputBorder.none,
                        errorText: _titleError.isNotEmpty ? _titleError : null,
                      ),
                      onChanged: (_) => setState(() => _titleError = ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

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
                            color: Colors.grey.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'مبلغ (${currency.symbol}) *',
                              hintText: '۰',
                              border: InputBorder.none,
                              errorText: _amountError.isNotEmpty ? _amountError : null,
                            ),
                            onChanged: _onAmountChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                          TextFormField(
                            controller: _dateController,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'تاریخ *',
                              hintText: '۱۴۰۴/۰۵/۲۰',
                              border: InputBorder.none,
                              errorText: _dateError.isNotEmpty ? _dateError : null,
                              counterText: '',
                            ),
                            onChanged: (value) {
                              final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                              if (cleaned.isEmpty) {
                                _dateController.text = '';
                                setState(() => _dateError = '');
                                return;
                              }
                              String formatted = '';
                              for (int i = 0; i < cleaned.length && i < 8; i++) {
                                if (i == 4 || i == 6) {
                                  formatted += '/';
                                }
                                formatted += cleaned[i];
                              }
                              if (formatted != value) {
                                _dateController.text = formatted;
                                _dateController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _dateController.text.length),
                                );
                              }
                              setState(() => _dateError = '');
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'لطفاً تاریخ را وارد کنید';
                              }
                              if (!DateProvider.isValidShamsiDate(value.trim())) {
                                return 'فرمت تاریخ اشتباه است (۱۴۰۴/۰۵/۲۰)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== زمان =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                    TextFormField(
                      controller: _timeController,
                      maxLength: 5,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ساعت (اختیاری)',
                        hintText: '۱۲:۰۰',
                        border: InputBorder.none,
                        errorText: _timeError.isNotEmpty ? _timeError : null,
                        counterText: '',
                      ),
                      onChanged: _onTimeChanged,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        if (!Validators.isValidTime(value.trim())) {
                          return 'فرمت زمان اشتباه است (۱۲:۰۰)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== دسته‌بندی =====
              CategorySelector(
                selectedCategoryId: _selectedCategoryId,
                selectedCategoryName: _selectedCategoryName,
                type: _selectedType,
                onCategorySelected: (id, name) {
                  setState(() {
                    _selectedCategoryId = id;
                    _selectedCategoryName = name;
                  });
                },
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // ===== انتخاب حساب =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                      'منبع پرداخت',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedAccountId,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'cash',
                          child: Text('نقدی'),
                        ),
                        ...accounts.map((acc) {
                          final displayName = acc.type == 'bank'
                              ? '${acc.name} (${acc.getShortNumber()})'
                              : acc.type == 'card'
                                  ? '${acc.name} (${acc.getShortNumber()})'
                                  : acc.name;
                          return DropdownMenuItem(
                            value: acc.id,
                            child: Text(displayName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAccountId = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== طرف حساب =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'طرف حساب (اختیاری)',
                    hintText: 'مثلاً نانوایی، شرکت، شخص...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ===== مبلغ هدف (برای اهداف) =====
              if (_isGoal)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                      TextFormField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'مبلغ هدف (${currency.symbol}) *',
                          hintText: '۰',
                          border: InputBorder.none,
                          errorText: _targetError.isNotEmpty ? _targetError : null,
                        ),
                        onChanged: (value) {
                          if (_isTargetFormatting) return;
                          _isTargetFormatting = true;

                          final englishValue = _toEnglishDigits(value);
                          final cleaned = englishValue.replaceAll(RegExp(r'[^\d]'), '');
                          if (cleaned.isEmpty) {
                            _targetController.text = '';
                            _isTargetFormatting = false;
                            setState(() => _targetError = '');
                            return;
                          }
                          final number = int.tryParse(cleaned);
                          if (number != null) {
                            final formatter = NumberFormat.decimalPattern('en_US');
                            final formatted = formatter.format(number);
                            _targetController.text = _toPersianDigits(formatted);
                            _targetController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _targetController.text.length),
                            );
                          }
                          _isTargetFormatting = false;
                          setState(() => _targetError = '');
                        },
                        validator: (value) {
                          if (_isGoal) {
                            if (value == null || value.trim().isEmpty) {
                              return 'لطفاً مبلغ هدف را وارد کنید';
                            }
                            final cleaned = _toEnglishDigits(value).replaceAll(RegExp(r'[^\d]'), '');
                            if (double.tryParse(cleaned) == null) {
                              return 'مبلغ را به عدد وارد کنید';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              if (_isGoal) const SizedBox(height: 12),

              // ===== یادآوری =====
              if (_showReminderFields)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                        'یادآوری',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: _selectedReminder,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: _reminders.map((r) {
                          String label = r == 0 ? 'بدون یادآوری' : '$r ساعت قبل';
                          return DropdownMenuItem(
                            value: r,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedReminder = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              if (_showReminderFields) const SizedBox(height: 12),

              // ===== الویت و تکرار =====
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
                            'الویت',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            items: _priorities.map((p) {
                              String label = p == 'low' ? 'کم' : p == 'medium' ? 'متوسط' : 'بالا';
                              return DropdownMenuItem(
                                value: p,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedPriority = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                            'تکرار',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: _selectedRecurrence,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            items: _recurrences.map((r) {
                              String label = r == 'once' ? 'یکبار' : r == 'monthly' ? 'ماهانه' : 'سالانه';
                              return DropdownMenuItem(
                                value: r,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedRecurrence = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== یادداشت =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'یادداشت (اختیاری)',
                    hintText: 'توضیحات بیشتر...',
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ===== دکمه ذخیره =====
              ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEditing ? 'ویرایش' : 'افزودن',
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