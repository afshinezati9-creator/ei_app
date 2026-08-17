import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  // دسته‌بندی‌های پیش‌فرض
  final List<Category> _defaultCategories = [
    // مخارج
    Category(id: 'c1', name: 'خوراک', icon: '🍽️', type: 'expense', color: '#FF6B6B'),
    Category(id: 'c2', name: 'مسکن', icon: '🏠', type: 'expense', color: '#FDCB6E'),
    Category(id: 'c3', name: 'حمل و نقل', icon: '🚗', type: 'expense', color: '#6C5CE7'),
    Category(id: 'c4', name: 'خرید', icon: '🛍️', type: 'expense', color: '#00B894'),
    Category(id: 'c5', name: 'تفریح', icon: '🎮', type: 'expense', color: '#FD79A8'),
    Category(id: 'c6', name: 'آموزش', icon: '📚', type: 'expense', color: '#0984E3'),
    Category(id: 'c7', name: 'سلامت', icon: '🏥', type: 'expense', color: '#00CEC9'),
    Category(id: 'c8', name: 'قبوض', icon: '📄', type: 'expense', color: '#E17055'),
    // درآمد
    Category(id: 'c9', name: 'حقوق', icon: '💼', type: 'income', color: '#00B894'),
    Category(id: 'c10', name: 'پاداش', icon: '🎁', type: 'income', color: '#FDCB6E'),
    Category(id: 'c11', name: 'سود', icon: '📈', type: 'income', color: '#6C5CE7'),
    Category(id: 'c12', name: 'سایر درآمد', icon: '💰', type: 'income', color: '#00CEC9'),
    // پس‌انداز
    Category(id: 'c13', name: 'پس‌انداز', icon: '🏦', type: 'saving', color: '#0984E3'),
    // هدف
    Category(id: 'c14', name: 'هدف', icon: '🎯', type: 'goal', color: '#FDCB6E'),
    // وام
    Category(id: 'c15', name: 'وام مسکن', icon: '🏡', type: 'loan', color: '#6C5CE7'),
    Category(id: 'c16', name: 'وام خودرو', icon: '🚙', type: 'loan', color: '#00B894'),
    // قرض
    Category(id: 'c17', name: 'قرض', icon: '🤝', type: 'debt', color: '#E17055'),
    // طلبکاری
    Category(id: 'c18', name: 'طلب', icon: '📋', type: 'credit', color: '#FDCB6E'),
  ];

  CategoryProvider() {
    _loadCategories();
  }

  List<Category> getCategoriesByType(String type) {
    return _categories.where((c) => c.type == type).toList();
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await _saveCategories();
    notifyListeners();
  }

  Future<void> removeCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _saveCategories();
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('categories');
    if (data != null && data.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _categories = decoded.map((item) => Category.fromJson(item)).toList();
      } catch (e) {
        _categories = List.from(_defaultCategories);
      }
    } else {
      _categories = List.from(_defaultCategories);
      await _saveCategories();
    }
    notifyListeners();
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(_categories.map((c) => c.toJson()).toList());
    await prefs.setString('categories', jsonData);
  }
}