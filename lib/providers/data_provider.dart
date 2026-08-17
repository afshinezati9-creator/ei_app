import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class DataProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  List<Transaction> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  double getTotalByType(String type) {
    return _transactions
        .where((t) => t.type == type)
        .fold(0, (sum, t) => sum + t.amount);
  }

  List<Transaction> getRecentTransactions({int limit = 5}) {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _transactions.clear();
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> init() async {
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    if (data != null && data.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _transactions = decoded.map((item) => Transaction.fromJson(item)).toList();
      } catch (e) {
        _transactions = [];
      }
    } else {
      // داده‌های نمونه برای تست
      _transactions = [
        Transaction(
          id: '1',
          title: 'خرید نان',
          amount: 15000,
          date: '۱۴۰۴/۰۵/۱۲',
          type: 'expense',
          extra: 'نانوایی',
        ),
        Transaction(
          id: '2',
          title: 'بنزین',
          amount: 500000,
          date: '۱۴۰۴/۰۵/۱۱',
          type: 'expense',
        ),
        Transaction(
          id: '3',
          title: 'حقوق',
          amount: 15000000,
          date: '۱۴۰۴/۰۵/۱۰',
          type: 'income',
        ),
      ];
      await _saveToPrefs();
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', jsonData);
  }
}