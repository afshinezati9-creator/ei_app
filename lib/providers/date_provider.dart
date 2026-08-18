import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DateFormatType {
  shamsi,
  shamsiShort,
  gregorian,
  persianText,
}

class DateProvider extends ChangeNotifier {
  static const String _formatKey = 'date_format';
  DateFormatType _currentFormat = DateFormatType.shamsi;

  DateProvider() {
    _loadFormat();
  }

  DateFormatType get currentFormat => _currentFormat;

  Future<void> setFormat(DateFormatType format) async {
    _currentFormat = format;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_formatKey, format.name);
    notifyListeners();
  }

  Future<void> _loadFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_formatKey);
    if (saved != null) {
      try {
        _currentFormat = DateFormatType.values.firstWhere((e) => e.name == saved);
      } catch (_) {
        _currentFormat = DateFormatType.shamsi;
      }
    }
    notifyListeners();
  }

  String getToday() {
    final now = DateTime.now();
    final year = now.year - 621;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }

  static bool isValidShamsiDate(String date) {
    final regex = RegExp(r'^(\d{4})/(\d{2})/(\d{2})$');
    if (!regex.hasMatch(date)) return false;
    final parts = date.split('/');
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return false;
    if (year < 1300 || year > 1500) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    if (month <= 6 && day > 31) return false;
    if (month >= 7 && day > 30) return false;
    if (month == 12 && day > 29) {
      final isLeap = (year % 33 == 1 || year % 33 == 5 || year % 33 == 9 ||
          year % 33 == 13 || year % 33 == 17 || year % 33 == 22 ||
          year % 33 == 26 || year % 33 == 30);
      if (!isLeap && day > 29) return false;
    }
    return true;
  }

  String convertDate(String shamsiDate, DateFormatType format) {
    if (shamsiDate.isEmpty || !isValidShamsiDate(shamsiDate)) return shamsiDate;
    final parts = shamsiDate.split('/');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    switch (format) {
      case DateFormatType.shamsi:
      case DateFormatType.shamsiShort:
        return shamsiDate;
      case DateFormatType.gregorian:
        final gregorian = _toGregorian(year, month, day);
        return '${gregorian.year}/${gregorian.month.toString().padLeft(2, '0')}/${gregorian.day.toString().padLeft(2, '0')}';
      case DateFormatType.persianText:
        const monthNames = [
          'فروردین', 'اردیبهشت', 'خرداد', 'تیر',
          'مرداد', 'شهریور', 'مهر', 'آبان',
          'آذر', 'دی', 'بهمن', 'اسفند'
        ];
        return '$day ${monthNames[month - 1]} $year';
    }
  }

  static DateTime _toGregorian(int year, int month, int day) {
    final base = DateTime(2000, 1, 1);
    final days = (year - 1379) * 365 + (month - 1) * 30 + (day - 1);
    return base.add(Duration(days: days));
  }

  String getFormatLabel(DateFormatType format) {
    switch (format) {
      case DateFormatType.shamsi:
        return 'شمسی (۱۴۰۴/۰۵/۱۸)';
      case DateFormatType.shamsiShort:
        return 'شمسی کوتاه';
      case DateFormatType.gregorian:
        return 'میلادی';
      case DateFormatType.persianText:
        return 'متن فارسی (۱۸ مرداد ۱۴۰۴)';
    }
  }

  Map<String, String> getDefaultRange(String rangeType) {
    final today = getToday();
    final parts = today.split('/');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    String from, to;
    switch (rangeType) {
      case 'month':
        from = '$year/${month.toString().padLeft(2, '0')}/01';
        to = today;
        break;
      case 'quarter':
        final startMonth = ((month - 1) ~/ 3) * 3 + 1;
        from = '$year/${startMonth.toString().padLeft(2, '0')}/01';
        to = today;
        break;
      case 'year':
        from = '$year/01/01';
        to = today;
        break;
      default:
        from = today;
        to = today;
    }
    return {'from': from, 'to': to};
  }

  // ===== متد جدید برای رفع خطای stats_screen =====
  void setDateRange(String from, String to, {String rangeType = 'custom'}) {
    // فعلاً فقط برای رفع خطای کامپایل، نیازی به ذخیره‌سازی نیست
    print('Date range set: $from to $to ($rangeType)');
  }
}