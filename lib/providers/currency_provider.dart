import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _symbol = 'تومان';
  final List<String> _currencies = ['تومان', 'دلار', 'یورو', 'لیر'];

  CurrencyProvider() {
    _load();
  }

  String get symbol => _symbol;
  List<String> get currencies => _currencies;

  Future<void> setCurrency(String newSymbol) async {
    if (_currencies.contains(newSymbol)) {
      _symbol = newSymbol;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', newSymbol);
      notifyListeners();
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('currency');
    if (saved != null && _currencies.contains(saved)) {
      _symbol = saved;
    }
    notifyListeners();
  }

  String formatNumber(double value) {
    final english = NumberFormat.decimalPattern('en_US').format(value.round());
    return _toPersian(english);
  }

  String _toPersian(String number) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    return number.split('').map((char) {
      final index = english.indexOf(char);
      return index != -1 ? persian[index] : char;
    }).join('');
  }

  String formatCurrency(double amount) {
    return '${formatNumber(amount)} $symbol';
  }
}