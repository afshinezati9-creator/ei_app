// ============================================================
// مسیر: lib/providers/data_provider.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';
import '../models/account.dart';
import '../models/goal.dart';
import '../models/note.dart';
import '../models/note_category.dart';
import '../models/category.dart';
import 'date_provider.dart';

class DataProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<Account> _accounts = [];
  List<Goal> _goals = [];
  List<Note> _notes = [];
  List<NoteCategory> _noteCategories = [];
  List<Category> _categories = [];

  List<TransactionModel> get transactions => _transactions;
  List<Account> get accounts => _accounts;
  List<Goal> get goals => _goals;
  List<Note> get notes => _notes;
  List<NoteCategory> get noteCategories => _noteCategories;
  List<Category> get categories => _categories;

  // ===== تراکنش‌ها =====
  List<TransactionModel> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  double getTotalByType(String type) {
    return _transactions
        .where((t) => t.type == type)
        .fold(0, (sum, t) => sum + t.amount);
  }

  List<TransactionModel> getRecentTransactions({int limit = 5}) {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
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

  // ===== حساب‌ها =====
  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  double getTotalAccountsBalance() {
    return _accounts.fold(0, (sum, a) => sum + a.balance);
  }

  // ===== اهداف =====
  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  List<Goal> getGoalsByStatus(GoalStatus status) {
    return _goals.where((g) => g.status == status).toList();
  }

  List<Goal> getGoalsByPriority(GoalPriority priority) {
    return _goals.where((g) => g.priority == priority).toList();
  }

  List<Goal> getActiveGoals() {
    return _goals.where((g) => g.status == GoalStatus.inProgress).toList();
  }

  List<Goal> getCompletedGoals() {
    return _goals.where((g) => g.status == GoalStatus.completed).toList();
  }

  double getTotalGoalsProgress() {
    if (_goals.isEmpty) return 0;
    final totalProgress = _goals.fold(0.0, (sum, g) => sum + g.progress);
    return totalProgress / _goals.length;
  }

  Map<GoalStatus, int> getGoalsCountByStatus() {
    final Map<GoalStatus, int> count = {};
    for (var status in GoalStatus.values) {
      count[status] = _goals.where((g) => g.status == status).length;
    }
    return count;
  }

  void updateGoalStatus(Goal goal) {
    if (goal.currentAmount >= goal.targetAmount) {
      goal.status = GoalStatus.completed;
    } else if (goal.status != GoalStatus.cancelled) {
      goal.status = GoalStatus.inProgress;
    }
  }

  List<TransactionModel> getTransactionsByGoal(String goalId) {
    return _transactions.where((t) => t.goalId == goalId).toList();
  }

  double getTotalTransactionsForGoal(String goalId) {
    return _transactions
        .where((t) => t.goalId == goalId)
        .fold(0, (sum, t) => sum + t.amount);
  }

  List<Map<String, dynamic>> getGoalProgressHistory(String goalId) {
    final transactions = getTransactionsByGoal(goalId);
    final sorted = List<TransactionModel>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double cumulative = 0;
    final history = <Map<String, dynamic>>[];
    for (var t in sorted) {
      cumulative += t.amount;
      history.add({
        'date': t.date,
        'amount': t.amount,
        'cumulative': cumulative,
        'title': t.title,
      });
    }
    return history;
  }

  Future<void> updateGoalCurrentAmount(String goalId) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final total = getTotalTransactionsForGoal(goalId);
    final goal = _goals[goalIndex];
    final updatedGoal = goal.copyWith(
      currentAmount: total,
    );
    _goals[goalIndex] = updatedGoal;
    updateGoalStatus(updatedGoal);
    await _saveToPrefs();
    notifyListeners();
  }

  // ===== یادداشت‌ها =====
  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  // ===== دسته‌بندی‌های یادداشت =====
  Future<void> addNoteCategory(NoteCategory category) async {
    _noteCategories.add(category);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteNoteCategory(String id) async {
    for (var note in _notes) {
      if (note.categoryId == id) {
        final updatedNote = Note(
          id: note.id,
          title: note.title,
          body: note.body,
          categoryId: '',
          created: note.created,
          updated: note.updated,
        );
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[index] = updatedNote;
        }
      }
    }
    _noteCategories.removeWhere((c) => c.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  List<Note> getNotesByCategory(String categoryId) {
    return _notes.where((n) => n.categoryId == categoryId).toList();
  }

  NoteCategory? getNoteCategory(String id) {
    try {
      return _noteCategories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // ===== دسته‌بندی‌های تراکنش =====
  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  List<Category> getCategoriesByType(String type) {
    return _categories.where((c) => c.type == type).toList();
  }

  // ===== مقداردهی اولیه =====
  Future<void> init() async {
    await _loadFromPrefs();

    if (_categories.isEmpty) {
      _addDefaultCategories();
      await _saveToPrefs();
    }

    if (_transactions.isEmpty) {
      _addSampleTransactions();
      await _saveToPrefs();
    }

    if (_accounts.isEmpty) {
      _addSampleAccounts();
      await _saveToPrefs();
    }

    if (_noteCategories.isEmpty) {
      _addSampleNoteCategories();
      await _saveToPrefs();
    }

    if (_notes.isEmpty) {
      _addSampleNotes();
      await _saveToPrefs();
    }

    if (_goals.isEmpty) {
      _addSampleGoals();
      await _saveToPrefs();
    }

    for (var goal in _goals) {
      updateGoalStatus(goal);
    }
  }

  // ===== داده‌های نمونه =====
  void _addDefaultCategories() {
    _categories.addAll([
      Category(id: 'cat_exp_food', name: 'خوراک', icon: '🍽️', type: 'expense', color: '#FF6B6B'),
      Category(id: 'cat_exp_house', name: 'مسکن', icon: '🏠', type: 'expense', color: '#FDCB6E'),
      Category(id: 'cat_exp_transport', name: 'حمل و نقل', icon: '🚗', type: 'expense', color: '#0984E3'),
      Category(id: 'cat_exp_health', name: 'بهداشت', icon: '🏥', type: 'expense', color: '#00B894'),
      Category(id: 'cat_inc_salary', name: 'حقوق', icon: '💼', type: 'income', color: '#00B894'),
      Category(id: 'cat_inc_project', name: 'پروژه', icon: '💻', type: 'income', color: '#0984E3'),
      Category(id: 'cat_save_fund', name: 'صندوق', icon: '🏦', type: 'saving', color: '#0984E3'),
      Category(id: 'cat_save_stock', name: 'سهام', icon: '📊', type: 'saving', color: '#6C5CE7'),
      Category(id: 'cat_goal_buy', name: 'خرید', icon: '🛒', type: 'goal', color: '#6C5CE7'),
      Category(id: 'cat_goal_travel', name: 'سفر', icon: '✈️', type: 'goal', color: '#0984E3'),
      Category(id: 'cat_loan_house', name: 'مسکن', icon: '🏠', type: 'loan', color: '#6C5CE7'),
      Category(id: 'cat_loan_car', name: 'خودرو', icon: '🚗', type: 'loan', color: '#0984E3'),
      Category(id: 'cat_debt_friend', name: 'دوستان', icon: '🤝', type: 'debt', color: '#E84393'),
      Category(id: 'cat_debt_family', name: 'خانواده', icon: '👨‍👩‍👦', type: 'debt', color: '#6C5CE7'),
      Category(id: 'cat_credit_friend', name: 'دوستان', icon: '🤝', type: 'credit', color: '#00B894'),
      Category(id: 'cat_credit_client', name: 'مشتری', icon: '👔', type: 'credit', color: '#0984E3'),
    ]);
  }

  void _addSampleNoteCategories() {
    _noteCategories.addAll([
      NoteCategory(id: 'cat_work', name: 'کاری', color: '#6C5CE7'),
      NoteCategory(id: 'cat_personal', name: 'شخصی', color: '#00B894'),
      NoteCategory(id: 'cat_ideas', name: 'ایده‌ها', color: '#FDCB6E'),
      NoteCategory(id: 'cat_others', name: 'متفرقه', color: '#636E72'),
    ]);
  }

  void _addSampleTransactions() {
    final dateProvider = DateProvider();
    final today = dateProvider.getToday();
    _transactions.addAll([
      TransactionModel(
        id: 'sample_1',
        title: 'خرید نان',
        amount: 15000,
        date: today,
        time: '۱۰:۳۰',
        type: 'expense',
        categoryId: 'cat_exp_food',
        categoryName: 'خوراک',
        paymentMethod: 'cash',
        contact: 'نانوایی',
        note: 'نان سنگک',
      ),
      TransactionModel(
        id: 'sample_2',
        title: 'حقوق ماهانه',
        amount: 15000000,
        date: today,
        time: '۰۹:۰۰',
        type: 'income',
        categoryId: 'cat_inc_salary',
        categoryName: 'حقوق',
        paymentMethod: 'cash',
        contact: 'شرکت',
        note: 'حقوق مرداد',
      ),
      TransactionModel(
        id: 'sample_3',
        title: 'بنزین',
        amount: 500000,
        date: today,
        time: '۱۴:۲۰',
        type: 'expense',
        categoryId: 'cat_exp_transport',
        categoryName: 'حمل و نقل',
        paymentMethod: 'cash',
        contact: 'پمپ بنزین',
        note: '',
      ),
      TransactionModel(
        id: 'sample_4',
        title: 'پس‌انداز ماهانه',
        amount: 2000000,
        date: today,
        time: '۱۲:۰۰',
        type: 'saving',
        categoryId: 'cat_save_fund',
        categoryName: 'صندوق',
        paymentMethod: 'cash',
        contact: '',
        note: 'برای خرید خانه',
      ),
    ]);
  }

  void _addSampleAccounts() {
    _accounts.addAll([
      Account(
        id: 'acc_cash',
        name: 'نقدی',
        type: 'cash',
        number: '',
        holder: '',
        balance: 5000000,
      ),
    ]);
  }

  void _addSampleNotes() {
    final dateProvider = DateProvider();
    final today = dateProvider.getToday();
    _notes.addAll([
      Note(
        id: 'note_1',
        title: 'برنامه مالی ماهانه',
        body: '۱. حقوق: ۱۵,۰۰۰,۰۰۰\n۲. اجاره: ۳,۰۰۰,۰۰۰\n۳. خوراک: ۲,۵۰۰,۰۰۰\n۴. پس‌انداز: ۲,۰۰۰,۰۰۰',
        categoryId: 'cat_personal',
        created: '$today ۱۰:۰۰',
        updated: '$today ۱۰:۰۰',
      ),
      Note(
        id: 'note_2',
        title: 'ایده‌های کسب‌وکار',
        body: '۱. فروشگاه آنلاین\n۲. مشاوره مالی\n۳. تولید محتوا',
        categoryId: 'cat_ideas',
        created: '$today ۱۴:۳۰',
        updated: '$today ۱۴:۳۰',
      ),
      Note(
        id: 'note_3',
        title: 'پروژه‌های کاری',
        body: '۱. تکمیل اپلیکیشن\n۲. جلسه با تیم\n۳. بررسی گزارش‌ها',
        categoryId: 'cat_work',
        created: '$today ۰۹:۱۵',
        updated: '$today ۰۹:۱۵',
      ),
    ]);
  }

  void _addSampleGoals() {
    final dateProvider = DateProvider();
    final today = dateProvider.getToday();

    _goals.addAll([
      Goal(
        id: 'goal_1',
        title: 'خرید لپ‌تاپ جدید',
        description: 'لپ‌تاپ برای کارهای برنامه‌نویسی و پروژه‌های دانشگاهی',
        targetAmount: 30000000,
        currentAmount: 12000000,
        deadline: '۱۴۰۴/۰۹/۰۱',
        priority: GoalPriority.high,
        status: GoalStatus.inProgress,
        color: '#6C5CE7',
        note: 'مدل دلخواه: مک‌بوک پرو M3',
        createdAt: today,
      ),
      Goal(
        id: 'goal_2',
        title: 'سفر به شمال',
        description: 'تعطیلات تابستان با خانواده',
        targetAmount: 15000000,
        currentAmount: 5000000,
        deadline: '۱۴۰۴/۰۷/۱۵',
        priority: GoalPriority.medium,
        status: GoalStatus.inProgress,
        color: '#00B894',
        note: 'مقصد: رامسر',
        createdAt: today,
      ),
      Goal(
        id: 'goal_3',
        title: 'پس‌انداز خرید خانه',
        description: 'پیش‌پرداخت خرید آپارتمان',
        targetAmount: 200000000,
        currentAmount: 45000000,
        deadline: '۱۴۰۵/۰۳/۰۱',
        priority: GoalPriority.high,
        status: GoalStatus.inProgress,
        color: '#0984E3',
        note: 'منطقه مورد نظر: تهرانپارس',
        createdAt: today,
      ),
      Goal(
        id: 'goal_4',
        title: 'خرید دوچرخه',
        description: 'دوچرخه کوهستان برای ورزش',
        targetAmount: 8000000,
        currentAmount: 8000000,
        deadline: '۱۴۰۴/۰۴/۱۵',
        priority: GoalPriority.low,
        status: GoalStatus.completed,
        color: '#00B894',
        note: '',
        createdAt: today,
      ),
    ]);
  }

  // ===== ذخیره‌سازی و بارگذاری =====
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final String? transData = prefs.getString('transactions');
    if (transData != null && transData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(transData);
        _transactions = decoded.map((item) => TransactionModel.fromJson(item)).toList();
      } catch (e) {
        _transactions = [];
      }
    }

    final String? accData = prefs.getString('accounts');
    if (accData != null && accData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(accData);
        _accounts = decoded.map((item) => Account.fromJson(item)).toList();
      } catch (e) {
        _accounts = [];
      }
    }

    final String? goalData = prefs.getString('goals');
    if (goalData != null && goalData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(goalData);
        _goals = decoded.map((item) => Goal.fromJson(item)).toList();
      } catch (e) {
        _goals = [];
      }
    }

    final String? noteData = prefs.getString('notes');
    if (noteData != null && noteData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(noteData);
        _notes = decoded.map((item) => Note.fromJson(item)).toList();
      } catch (e) {
        _notes = [];
      }
    }

    final String? noteCatData = prefs.getString('note_categories');
    if (noteCatData != null && noteCatData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(noteCatData);
        _noteCategories = decoded.map((item) => NoteCategory.fromJson(item)).toList();
      } catch (e) {
        _noteCategories = [];
      }
    }

    final String? catData = prefs.getString('categories');
    if (catData != null && catData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(catData);
        _categories = decoded.map((item) => Category.fromJson(item)).toList();
      } catch (e) {
        _categories = [];
      }
    }

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
    await prefs.setString('accounts', jsonEncode(_accounts.map((a) => a.toJson()).toList()));
    await prefs.setString('goals', jsonEncode(_goals.map((g) => g.toJson()).toList()));
    await prefs.setString('notes', jsonEncode(_notes.map((n) => n.toJson()).toList()));
    await prefs.setString('note_categories', jsonEncode(_noteCategories.map((c) => c.toJson()).toList()));
    await prefs.setString('categories', jsonEncode(_categories.map((c) => c.toJson()).toList()));
  }

  // ===== پاک کردن و خروجی JSON =====
  Future<void> clearAllData() async {
    _transactions.clear();
    _accounts.clear();
    _goals.clear();
    _notes.clear();
    _noteCategories.clear();
    _categories.clear();
    await _saveToPrefs();
    notifyListeners();
  }

  String toJson() {
    return jsonEncode({
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'accounts': _accounts.map((a) => a.toJson()).toList(),
      'goals': _goals.map((g) => g.toJson()).toList(),
      'notes': _notes.map((n) => n.toJson()).toList(),
      'note_categories': _noteCategories.map((c) => c.toJson()).toList(),
      'categories': _categories.map((c) => c.toJson()).toList(),
    });
  }
}