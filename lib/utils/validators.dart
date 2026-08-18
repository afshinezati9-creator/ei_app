class Validators {
  // ===== وریفای تاریخ شمسی =====
  static bool isValidDate(String date) {
    if (date.isEmpty) return false;
    final regex = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    if (!regex.hasMatch(date)) return false;
    final parts = date.split('/');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    if (year < 1300 || year > 1500) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    // بررسی ماه‌های ۳۰ روزه
    if ([4, 6, 9, 11].contains(month) && day > 30) return false;
    // بررسی اسفند (ماه ۱۲) برای سال کبیسه
    if (month == 12 && day > 30) return false;
    return true;
  }

  // ===== وریفای زمان =====
  static bool isValidTime(String time) {
    if (time.isEmpty) return false;
    final regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(time)) return false;
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  // ===== وریفای مبلغ =====
  static bool isValidAmount(String amount) {
    if (amount.isEmpty) return false;
    final cleaned = amount.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return false;
    final num = double.tryParse(cleaned);
    return num != null && num > 0;
  }

  // ===== وریفای بازه زمانی =====
  static bool isValidDateRange(String from, String to) {
    if (from.isEmpty || to.isEmpty) return false;
    if (!isValidDate(from) || !isValidDate(to)) return false;
    return from.compareTo(to) <= 0;
  }

  // ===== وریفای رمز عبور (۶ رقم) =====
  static bool isValidPassword(String password) {
    return password.length == 6 && RegExp(r'^\d{6}$').hasMatch(password);
  }

  // ===== وریفای شماره حساب (حداقل ۱۰ رقم) =====
  static bool isValidAccountNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10;
  }

  // ===== وریفای ایمیل =====
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // ===== وریفای تلفن =====
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 11;
  }

  // ===== دریافت پیام خطا =====
  static String getDateErrorMessage(String date) {
    if (date.isEmpty) return 'تاریخ را وارد کنید';
    if (!RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(date)) {
      return 'فرمت تاریخ را رعایت کنید (۱۴۰۴/۰۵/۲۰)';
    }
    final parts = date.split('/');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    if (year < 1300 || year > 1500) return 'سال باید بین ۱۳۰۰ تا ۱۵۰۰ باشد';
    if (month < 1 || month > 12) return 'ماه باید بین ۱ تا ۱۲ باشد';
    if (day < 1 || day > 31) return 'روز باید بین ۱ تا ۳۱ باشد';
    if ([4, 6, 9, 11].contains(month) && day > 30) {
      return 'این ماه ۳۰ روز دارد';
    }
    if (month == 12 && day > 30) return 'اسفند ۳۰ روز دارد';
    return 'تاریخ معتبر است';
  }

  static String getTimeErrorMessage(String time) {
    if (time.isEmpty) return 'زمان را وارد کنید';
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(time)) {
      return 'فرمت زمان را رعایت کنید (۱۲:۰۰)';
    }
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (hour < 0 || hour > 23) return 'ساعت باید بین ۰ تا ۲۳ باشد';
    if (minute < 0 || minute > 59) return 'دقیقه باید بین ۰ تا ۵۹ باشد';
    return 'زمان معتبر است';
  }

  static String getAmountErrorMessage(String amount) {
    if (amount.isEmpty) return 'مبلغ را وارد کنید';
    final cleaned = amount.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return 'مبلغ را به عدد وارد کنید';
    final num = double.tryParse(cleaned);
    if (num == null || num <= 0) return 'مبلغ باید بزرگتر از صفر باشد';
    return 'مبلغ معتبر است';
  }

  static String getDateRangeErrorMessage(String from, String to) {
    if (from.isEmpty || to.isEmpty) return 'هر دو تاریخ را وارد کنید';
    if (!isValidDate(from)) return 'تاریخ شروع نامعتبر است';
    if (!isValidDate(to)) return 'تاریخ پایان نامعتبر است';
    if (from.compareTo(to) > 0) {
      return 'تاریخ شروع نباید از تاریخ پایان بزرگتر باشد';
    }
    return 'بازه زمانی معتبر است';
  }

  static String getPasswordErrorMessage(String password) {
    if (password.isEmpty) return 'رمز عبور را وارد کنید';
    if (password.length != 6) return 'رمز باید دقیقاً ۶ رقم باشد';
    if (!RegExp(r'^\d{6}$').hasMatch(password)) return 'رمز فقط باید شامل عدد باشد';
    return 'رمز معتبر است';
  }

  static String getAccountNumberErrorMessage(String number) {
    if (number.isEmpty) return 'شماره حساب را وارد کنید';
    final cleaned = number.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10) return 'شماره باید حداقل ۱۰ رقم باشد';
    return 'شماره معتبر است';
  }
}