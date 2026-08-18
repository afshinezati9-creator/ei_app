import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/date_provider.dart';

// ✅ TextInputFormatter برای فرمت خودکار تاریخ شمسی
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

class DateRangePicker extends StatefulWidget {
  final Function(String from, String to, String rangeType) onRangeSelected;

  const DateRangePicker({
    super.key,
    required this.onRangeSelected,
  });

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  String _selectedRange = 'month';
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  String _errorMessage = '';
  bool _isFromValid = true;
  bool _isToValid = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized && mounted) {
        _setDefaultRange('month');
        _isInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _setDefaultRange(String rangeType) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final defaultRange = dateProvider.getDefaultRange(rangeType);
    final from = defaultRange['from'] ?? '';
    final to = defaultRange['to'] ?? '';

    _fromController.text = from;
    _toController.text = to;
    _selectedRange = rangeType;
    _errorMessage = '';
    _isFromValid = true;
    _isToValid = true;
    widget.onRangeSelected(from, to, rangeType);
  }

  void _validateAndApply() {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    // ✅ اعتبارسنجی با متد استاتیک
    final fromValid = DateProvider.isValidShamsiDate(from);
    final toValid = DateProvider.isValidShamsiDate(to);

    setState(() {
      _isFromValid = fromValid || from.isEmpty;
      _isToValid = toValid || to.isEmpty;
    });

    if (!fromValid) {
      setState(() => _errorMessage = '⚠️ فرمت تاریخ شروع اشتباه است (۱۴۰۴/۰۵/۲۰)');
      return;
    }
    if (!toValid) {
      setState(() => _errorMessage = '⚠️ فرمت تاریخ پایان اشتباه است (۱۴۰۴/۰۵/۲۰)');
      return;
    }

    // ✅ مقایسه رشته‌ای (چون فرمت یکسان است)
    if (from.compareTo(to) > 0) {
      setState(() => _errorMessage = '⚠️ تاریخ شروع نباید از تاریخ پایان بزرگتر باشد');
      return;
    }

    setState(() => _errorMessage = '');
    _selectedRange = 'custom';
    widget.onRangeSelected(from, to, 'custom');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildRangeChip('ماهانه', 'month'),
              _buildRangeChip('سه‌ماهه', 'quarter'),
              _buildRangeChip('سالانه', 'year'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fromController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    _ShamsiDateFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'از تاریخ',
                    hintText: '۱۴۰۴/۰۱/۰۱',
                    errorText: _isFromValid ? null : 'فرمت اشتباه',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    counterText: '',
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) {
                    setState(() {
                      _errorMessage = '';
                      _isFromValid = true;
                      _isToValid = true;
                    });
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _toController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    _ShamsiDateFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'تا تاریخ',
                    hintText: '۱۴۰۴/۱۲/۲۹',
                    errorText: _isToValid ? null : 'فرمت اشتباه',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    counterText: '',
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) {
                    setState(() {
                      _errorMessage = '';
                      _isFromValid = true;
                      _isToValid = true;
                    });
                  },
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: _validateAndApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text('اعمال', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          if (_selectedRange != 'custom' && _fromController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'بازه: ${_fromController.text} تا ${_toController.text}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(String label, String value) {
    final isSelected = _selectedRange == value;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _errorMessage = '';
            _isFromValid = true;
            _isToValid = true;
          });
          _setDefaultRange(value);
        }
      },
      selectedColor: const Color(0xFF6C5CE7),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontSize: 12,
      ),
    );
  }
}