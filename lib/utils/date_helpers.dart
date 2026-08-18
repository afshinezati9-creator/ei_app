class DateHelpers {
  // ===== دریافت تاریخ امروز به شمسی =====
  static String getToday() {
    final now = DateTime.now();
    return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  }

  // ===== دریافت زمان فعلی =====
  static String getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // ===== تبدیل تاریخ شمسی به میلادی (تقریبی) =====
  static DateTime persianToGregorian(String persianDate) {
    final parts = persianDate.split('/');
    if (parts.length != 3) return DateTime.now();
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    // تبدیل تقریبی (برای مقایسه بازه‌ها)
    final base = DateTime(2000, 1, 1);
    final days = (year - 1379) * 365 + (month - 1) * 30 + (day - 1);
    return base.add(Duration(days: days));
  }

  // ===== مقایسه دو تاریخ شمسی =====
  static int compareDates(String date1, String date2) {
    if (date1.isEmpty || date2.isEmpty) return 0;
    return date1.compareTo(date2);
  }

  // ===== بررسی اینکه تاریخ در بازه است =====
  static bool isDateInRange(String date, String from, String to) {
    if (from.isEmpty || to.isEmpty) return true;
    return date.compareTo(from) >= 0 && date.compareTo(to) <= 0;
  }

  // ===== دریافت ماه از تاریخ =====
  static String getMonthFromDate(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('/');
    if (parts.length != 3) return '';
    return parts[1];
  }

  // ===== دریافت سال از تاریخ =====
  static String getYearFromDate(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('/');
    if (parts.length != 3) return '';
    return parts[0];
  }

  // ===== دریافت نام ماه =====
  static String getMonthName(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('/');
    if (parts.length != 3) return '';
    final month = int.parse(parts[1]);
    const monthNames = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر',
      'مرداد', 'شهریور', 'مهر', 'آبان',
      'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    return monthNames[month - 1];
  }

  // ===== دریافت روز هفته =====
  static String getWeekday(String date) {
    final gregorian = persianToGregorian(date);
    const weekdays = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];
    return weekdays[gregorian.weekday % 7];
  }

  // ===== افزایش تاریخ به میزان روز =====
  static String addDays(String date, int days) {
    final gregorian = persianToGregorian(date);
    final newDate = gregorian.add(Duration(days: days));
    // تبدیل به شمسی تقریبی
    final base = DateTime(2000, 1, 1);
    final diff = newDate.difference(base);
    final totalDays = diff.inDays;
    final year = 1379 + (totalDays ~/ 365);
    final remainingDays = totalDays % 365;
    final month = remainingDays ~/ 30 + 1;
    final day = remainingDays % 30 + 1;
    return '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
  }

  // ===== کاهش تاریخ به میزان روز =====
  static String subtractDays(String date, int days) {
    return addDays(date, -days);
  }

  // ===== بررسی اینکه آیا تاریخ امروز است =====
  static bool isToday(String date) {
    return date == getToday();
  }

  // ===== بررسی اینکه آیا تاریخ در ماه جاری است =====
  static bool isCurrentMonth(String date) {
    final today = getToday();
    return getMonthFromDate(date) == getMonthFromDate(today) &&
        getYearFromDate(date) == getYearFromDate(today);
  }
}