import 'package:intl/intl.dart';

class Formatters {
  // ===== تبدیل اعداد به فارسی =====
  static String toPersianDigits(String number) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    return number.split('').map((char) {
      final index = english.indexOf(char);
      return index != -1 ? persian[index] : char;
    }).join('');
  }

  static String formatNumber(double value) {
    final formatter = NumberFormat.decimalPattern('en_US');
    final english = formatter.format(value.round());
    return toPersianDigits(english);
  }

  static String formatNumberWithCommas(double value) {
    final formatter = NumberFormat.decimalPattern('en_US');
    final english = formatter.format(value);
    return toPersianDigits(english);
  }

  // ===== فرمت تاریخ =====
  static String formatDate(String date) {
    if (date.isEmpty) return '';
    return date;
  }

  // ===== فرمت زمان =====
  static String formatTime(String time) {
    if (time.isEmpty) return '';
    if (time.length == 4) {
      return '${time.substring(0, 2)}:${time.substring(2)}';
    }
    return time;
  }

  // ===== فرمت مبلغ =====
  static String formatAmount(double amount) {
    return formatNumber(amount);
  }

  static String formatAmountWithSymbol(double amount, String symbol) {
    return '${formatNumber(amount)} $symbol';
  }

  // ===== تبدیل رشته به عدد =====
  static double parseAmount(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return 0;
    return double.parse(cleaned);
  }

  // ===== تبدیل عدد به فرمت سه‌رقمی =====
  static String formatWithCommas(String value) {
    if (value.isEmpty) return '';
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return '';
    final number = int.parse(cleaned);
    final formatter = NumberFormat.decimalPattern('en_US');
    final english = formatter.format(number);
    return toPersianDigits(english);
  }

  // ===== مخفی کردن شماره حساب =====
  static String maskAccountNumber(String number) {
    if (number.length < 4) return number;
    final visible = number.substring(number.length - 4);
    return '•••• $visible';
  }

  // ===== دریافت ۴ رقم آخر =====
  static String getLastFourDigits(String number) {
    if (number.length < 4) return number;
    return number.substring(number.length - 4);
  }

  // ===== تبدیل ارز =====
  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'تومان': return 'تومان';
      case 'دلار': return '\$';
      case 'یورو': return '€';
      case 'لیر': return '₺';
      case 'درهم': return 'د.إ';
      default: return currency;
    }
  }
}