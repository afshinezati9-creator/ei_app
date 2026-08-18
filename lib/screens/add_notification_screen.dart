// ============================================================
// مسیر: lib/screens/add_notification_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/notification.dart';
import '../providers/providers.dart';
import '../providers/notification_provider.dart';
import '../providers/date_provider.dart';

class AddNotificationScreen extends StatefulWidget {
  final AppNotification? notification;

  const AddNotificationScreen({super.key, this.notification});

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String _selectedCategory = 'سفارشی';
  NotificationType _selectedType = NotificationType.custom;
  NotificationPriority _selectedPriority = NotificationPriority.medium;
  bool _isRecurring = false;
  String _selectedRecurringType = 'daily';
  String _newCategory = '';

  bool _isEditing = false;
  bool _showAddCategory = false;

  final List<String> _recurringOptions = ['daily', 'weekly', 'monthly'];
  final Map<String, String> _recurringLabels = {
    'daily': 'روزانه',
    'weekly': 'هفتگی',
    'monthly': 'ماهانه',
  };

  String _titleError = '';
  String _dateError = '';
  String _timeError = '';

  @override
  void initState() {
    super.initState();
    _isEditing = widget.notification != null;
    final dateProvider = DateProvider();

    if (widget.notification != null) {
      final n = widget.notification!;
      _titleController.text = n.title;
      _bodyController.text = n.body;
      _dateController.text = n.scheduledDate;
      _timeController.text = n.scheduledTime;
      _expiryDateController.text = n.expiryDate ?? '';
      _selectedCategory = n.category;
      _selectedType = n.type;
      _selectedPriority = n.priority;
      _isRecurring = n.isRecurring;
      _selectedRecurringType = n.recurringType ?? 'daily';
    } else {
      _dateController.text = dateProvider.getToday();
      _timeController.text = _getCurrentTime();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // ===== تبدیل اعداد فارسی به انگلیسی =====
  String _toEnglishDigits(String text) {
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    const english = '0123456789';
    return text.split('').map((char) {
      final index = persian.indexOf(char);
      return index != -1 ? english[index] : char;
    }).join('');
  }

  // ===== تبدیل اعداد انگلیسی به فارسی =====
  String _toPersianDigits(String number) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    return number.split('').map((char) {
      final index = english.indexOf(char);
      return index != -1 ? persian[index] : char;
    }).join('');
  }

  // ===== فرمت‌کننده تاریخ شمسی =====
  void _onDateChanged(String value) {
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
    _dateController.text = formatted;
    _dateController.selection = TextSelection.fromPosition(
      TextPosition(offset: _dateController.text.length),
    );
    setState(() => _dateError = '');
  }

  // ===== فرمت‌کننده ساعت =====
  void _onTimeChanged(String value) {
    final cleaned = _toEnglishDigits(value).replaceAll(RegExp(r'[^0-9]'), '');
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

  // ===== اعتبارسنجی و ذخیره =====
  void _saveNotification() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '⚠️ عنوان اعلان را وارد کنید');
      return;
    } else {
      setState(() => _titleError = '');
    }

    final date = _dateController.text.trim();
    if (!DateProvider.isValidShamsiDate(date)) {
      setState(() => _dateError = '⚠️ فرمت تاریخ اشتباه است (۱۴۰۴/۰۵/۲۰)');
      return;
    } else {
      setState(() => _dateError = '');
    }

    final time = _timeController.text.trim();
    if (time.isEmpty || !_isValidTime(time)) {
      setState(() => _timeError = '⚠️ فرمت زمان اشتباه است (۱۴:۳۰)');
      return;
    } else {
      setState(() => _timeError = '');
    }

    final dateProvider = DateProvider();
    final now = '${dateProvider.getToday()} ${_getCurrentTime()}';

    final notification = AppNotification(
      id: widget.notification?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: _bodyController.text.trim(),
      scheduledDate: date,
      scheduledTime: time,
      expiryDate: _expiryDateController.text.trim().isNotEmpty
          ? _expiryDateController.text.trim()
          : null,
      status: widget.notification?.status ?? NotificationStatus.pending,
      type: _selectedType,
      category: _selectedCategory,
      priority: _selectedPriority,
      isRecurring: _isRecurring,
      recurringType: _isRecurring ? _selectedRecurringType : null,
      relatedId: widget.notification?.relatedId,
      createdAt: widget.notification?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<NotificationProvider>();

    if (_isEditing) {
      provider.updateNotification(notification);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ اعلان ویرایش شد')),
      );
    } else {
      provider.addNotification(notification);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ اعلان اضافه شد')),
      );
    }

    Navigator.pop(context, true);
  }

  bool _isValidTime(String time) {
    final regex = RegExp(r'^(\d{2}):(\d{2})$');
    if (!regex.hasMatch(time)) return false;
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  void _addNewCategory() {
    final name = _newCategory.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ نام دسته‌بندی را وارد کنید')),
      );
      return;
    }
    final provider = context.read<NotificationProvider>();
    provider.addCategory(name);
    setState(() {
      _selectedCategory = name;
      _newCategory = '';
      _showAddCategory = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ دسته‌بندی "$name" اضافه شد')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش اعلان' : 'اعلان جدید'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(context),
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
                    labelText: 'عنوان *',
                    hintText: 'مثلاً چک شماره ۱۲۳۴۵',
                    border: InputBorder.none,
                    errorText: _titleError.isNotEmpty ? _titleError : null,
                  ),
                  onChanged: (_) => setState(() => _titleError = ''),
                ),
              ),
              const SizedBox(height: 12),

              // ===== متن اعلان =====
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
                  controller: _bodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'متن اعلان',
                    hintText: 'توضیحات بیشتر...',
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ===== تاریخ و ساعت =====
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
                        onChanged: _onDateChanged,
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
                        controller: _timeController,
                        maxLength: 5,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ساعت *',
                          hintText: '۱۴:۳۰',
                          border: InputBorder.none,
                          errorText: _timeError.isNotEmpty ? _timeError : null,
                          counterText: '',
                        ),
                        onChanged: _onTimeChanged,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== تاریخ انقضا =====
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
                  controller: _expiryDateController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'تاریخ انقضا (اختیاری)',
                    hintText: '۱۴۰۴/۰۶/۱۵',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (value) {
                    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (cleaned.isEmpty) {
                      _expiryDateController.text = '';
                      return;
                    }
                    String formatted = '';
                    for (int i = 0; i < cleaned.length && i < 8; i++) {
                      if (i == 4 || i == 6) {
                        formatted += '/';
                      }
                      formatted += cleaned[i];
                    }
                    _expiryDateController.text = formatted;
                    _expiryDateController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _expiryDateController.text.length),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // ===== نوع اعلان =====
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
                      'نوع اعلان',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: NotificationType.values.map((type) {
                        final isSelected = _selectedType == type;
                        final label = _getTypeLabel(type);
                        return FilterChip(
                          label: Text(label, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedType = type);
                            }
                          },
                          selectedColor: const Color(0xFF6C5CE7),
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

              // ===== دسته‌بندی =====
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
                      'دسته‌بندی',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!_showAddCategory)
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              items: categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedCategory = value);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF6C5CE7)),
                            onPressed: () {
                              setState(() => _showAddCategory = true);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    if (_showAddCategory)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) => _newCategory = value,
                              decoration: InputDecoration(
                                hintText: 'نام دسته جدید...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: _addNewCategory,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _showAddCategory = false;
                                _newCategory = '';
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                  ],
                ),
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
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: NotificationPriority.values.map((priority) {
                        final isSelected = _selectedPriority == priority;
                        final label = _getPriorityLabel(priority);
                        final color = _getPriorityColor(priority);
                        return FilterChip(
                          label: Text(label, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedPriority = priority);
                            }
                          },
                          selectedColor: color,
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

              // ===== تکرار =====
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تکرار',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: _isRecurring,
                          onChanged: (value) {
                            setState(() => _isRecurring = value);
                          },
                          activeColor: const Color(0xFF6C5CE7),
                        ),
                      ],
                    ),
                    if (_isRecurring)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _recurringOptions.map((option) {
                          final isSelected = _selectedRecurringType == option;
                          return FilterChip(
                            label: Text(
                              _recurringLabels[option] ?? option,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedRecurringType = option);
                              }
                            },
                            selectedColor: const Color(0xFF6C5CE7),
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
              const SizedBox(height: 20),

              // ===== دکمه ذخیره =====
              ElevatedButton(
                onPressed: _saveNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEditing ? 'ویرایش اعلان' : 'افزودن اعلان',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return 'یادآوری';
      case NotificationType.check:
        return 'چک';
      case NotificationType.task:
        return 'وظیفه';
      case NotificationType.goal:
        return 'هدف';
      case NotificationType.custom:
        return 'سفارشی';
    }
  }

  String _getPriorityLabel(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'کم';
      case NotificationPriority.medium:
        return 'متوسط';
      case NotificationPriority.high:
        return 'بالا';
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.high:
        return Colors.red;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف اعلان'),
        content: Text('آیا از حذف اعلان "${widget.notification?.title}" مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final provider = context.read<NotificationProvider>();
              provider.deleteNotification(widget.notification!.id);
              Navigator.pop(ctx);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ اعلان حذف شد')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}