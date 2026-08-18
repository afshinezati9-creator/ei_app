import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/providers.dart';
import '../widgets/goal_card.dart';
import 'add_goal_screen.dart' as addGoalScreen; // تغییر alias

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  GoalStatus? _selectedStatus;
  GoalPriority? _selectedPriority;
  String _searchQuery = '';
  int _currentPage = 1;
  int _pageSize = 10;

  List<Goal> get _filteredGoals {
    var list = context.watch<DataProvider>().goals;

    if (_selectedStatus != null) {
      list = list.where((g) => g.status == _selectedStatus).toList();
    }

    if (_selectedPriority != null) {
      list = list.where((g) => g.priority == _selectedPriority).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((g) =>
        g.title.toLowerCase().contains(query) ||
        g.description.toLowerCase().contains(query)
      ).toList();
    }

    list.sort((a, b) {
      final statusOrder = {
        GoalStatus.inProgress: 0,
        GoalStatus.completed: 1,
        GoalStatus.cancelled: 2,
      };
      final orderA = statusOrder[a.status] ?? 0;
      final orderB = statusOrder[b.status] ?? 0;
      if (orderA != orderB) return orderA.compareTo(orderB);
      return a.deadline.compareTo(b.deadline);
    });

    return list;
  }

  List<Goal> get _pageItems {
    final total = _filteredGoals.length;
    final totalPages = (total / _pageSize).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;

    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    return _filteredGoals.sublist(
      start,
      end > total ? total : end,
    );
  }

  int get _totalPages {
    return (_filteredGoals.length / _pageSize).ceil();
  }

  Map<GoalStatus, int> get _statusCount {
    final data = context.watch<DataProvider>();
    return data.getGoalsCountByStatus();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final theme = context.watch<ThemeProvider>();
    final currency = context.watch<CurrencyProvider>();
    final isDark = theme.isDarkMode(context);

    final goals = _pageItems;
    final totalCount = _filteredGoals.length;
    final statusCount = _statusCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اهداف'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو در اهداف...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
            ),
          ),

          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatusFilterChip('همه', null),
                _buildStatusFilterChip('در حال انجام', GoalStatus.inProgress),
                _buildStatusFilterChip('تکمیل شده', GoalStatus.completed),
                _buildStatusFilterChip('لغو شده', GoalStatus.cancelled),
                const SizedBox(width: 8),
                _buildPriorityFilterChip('همه اولویت‌ها', null),
                _buildPriorityFilterChip('کم', GoalPriority.low),
                _buildPriorityFilterChip('متوسط', GoalPriority.medium),
                _buildPriorityFilterChip('بالا', GoalPriority.high),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _statChip('همه', totalCount, Colors.grey),
                const SizedBox(width: 6),
                _statChip('در حال انجام', statusCount[GoalStatus.inProgress] ?? 0, Colors.orange),
                const SizedBox(width: 6),
                _statChip('تکمیل شده', statusCount[GoalStatus.completed] ?? 0, Colors.green),
                const SizedBox(width: 6),
                _statChip('لغو شده', statusCount[GoalStatus.cancelled] ?? 0, Colors.red),
                const Spacer(),
                Text(
                  'مجموع: ${currency.formatCurrency(data.getTotalByType('goal'))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty || _selectedStatus != null || _selectedPriority != null
                              ? 'نتیجه‌ای یافت نشد'
                              : 'هنوز هدفی ثبت نشده',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedStatus != null || _selectedPriority != null
                              ? 'فیلترهای خود را تغییر دهید'
                              : 'با دکمه + یک هدف جدید اضافه کنید',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return GoalCard(
                        goal: goal,
                        onLongPress: () {
                          _showGoalOptions(context, goal);
                        },
                      );
                    },
                  ),
          ),

          if (_filteredGoals.length > _pageSize)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text(
                    'صفحه $_currentPage از $_totalPages',
                    style: const TextStyle(fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'کل: ${_filteredGoals.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const addGoalScreen.AddGoalScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, GoalStatus? status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
            _currentPage = 1;
          });
        },
        selectedColor: status == GoalStatus.inProgress
            ? Colors.orange
            : status == GoalStatus.completed
                ? Colors.green
                : status == GoalStatus.cancelled
                    ? Colors.red
                    : const Color(0xFF6C5CE7),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildPriorityFilterChip(String label, GoalPriority? priority) {
    final isSelected = _selectedPriority == priority;
    Color color;
    if (priority == null) {
      color = Colors.grey;
    } else {
      color = priority == GoalPriority.low
          ? Colors.green
          : priority == GoalPriority.medium
              ? Colors.orange
              : Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedPriority = selected ? priority : null;
            _currentPage = 1;
          });
        },
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalOptions(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'گزینه‌ها',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF6C5CE7)),
              title: const Text('ویرایش هدف'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => addGoalScreen.AddGoalScreen(goal: goal),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            if (goal.status != GoalStatus.completed)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('علامت‌گذاری به عنوان تکمیل شده'),
                onTap: () {
                  final updatedGoal = goal.copyWith(
                    status: GoalStatus.completed,
                    currentAmount: goal.targetAmount,
                  );
                  context.read<DataProvider>().updateGoal(updatedGoal);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ هدف تکمیل شده علامت‌گذاری شد')),
                  );
                  setState(() {});
                },
              ),
            if (goal.status == GoalStatus.inProgress)
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('لغو هدف'),
                onTap: () {
                  final updatedGoal = goal.copyWith(
                    status: GoalStatus.cancelled,
                  );
                  context.read<DataProvider>().updateGoal(updatedGoal);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ هدف لغو شد')),
                  );
                  setState(() {});
                },
              ),
            if (goal.status == GoalStatus.cancelled || goal.status == GoalStatus.completed)
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.orange),
                title: const Text('بازگشت به در حال انجام'),
                onTap: () {
                  final updatedGoal = goal.copyWith(
                    status: GoalStatus.inProgress,
                  );
                  context.read<DataProvider>().updateGoal(updatedGoal);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔄 هدف به در حال انجام بازگشت')),
                  );
                  setState(() {});
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف هدف'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, goal);
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('بستن'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف هدف'),
        content: Text('آیا از حذف هدف "${goal.title}" مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              context.read<DataProvider>().deleteGoal(goal.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🗑️ هدف "${goal.title}" حذف شد')),
              );
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}