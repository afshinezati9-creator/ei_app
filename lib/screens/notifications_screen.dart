// ============================================================
// مسیر: lib/screens/notifications_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/notification.dart';
import '../widgets/notification_card.dart';
import 'add_notification_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'همه';
  String _selectedCategory = 'همه';
  int _currentPage = 1;
  final int _pageSize = 10;

  List<String> get _statusOptions => ['همه', 'در انتظار', 'دیده شده', 'بسته شده', 'منقضی'];

  List<AppNotification> get _filteredNotifications {
    var list = context.watch<NotificationProvider>().notifications;

    // جستجو
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((n) =>
        n.title.toLowerCase().contains(query) ||
        n.body.toLowerCase().contains(query)
      ).toList();
    }

    // فیلتر وضعیت
    if (_selectedStatus != 'همه') {
      final statusMap = {
        'در انتظار': NotificationStatus.pending,
        'دیده شده': NotificationStatus.shown,
        'بسته شده': NotificationStatus.dismissed,
        'منقضی': NotificationStatus.expired,
      };
      final status = statusMap[_selectedStatus];
      if (status != null) {
        list = list.where((n) => n.status == status).toList();
      }
    }

    // فیلتر دسته‌بندی
    if (_selectedCategory != 'همه') {
      list = list.where((n) => n.category == _selectedCategory).toList();
    }

    // مرتب‌سازی بر اساس تاریخ (جدیدترین اول)
    list.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    return list;
  }

  List<AppNotification> get _pageItems {
    final total = _filteredNotifications.length;
    final totalPages = (total / _pageSize).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;

    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    return _filteredNotifications.sublist(
      start,
      end > total ? total : end,
    );
  }

  int get _totalPages {
    return (_filteredNotifications.length / _pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode(context);

    final notifications = _pageItems;
    final categories = ['همه', ...provider.categories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلان‌ها'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(categories),
          ),
        ],
      ),
      body: Column(
        children: [
          // نمایش فیلترهای فعال
          if (_selectedStatus != 'همه' || _selectedCategory != 'همه')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (_selectedStatus != 'همه')
                    _buildFilterChip(
                      label: 'وضعیت: $_selectedStatus',
                      onRemove: () => setState(() => _selectedStatus = 'همه'),
                    ),
                  if (_selectedCategory != 'همه')
                    _buildFilterChip(
                      label: 'دسته: $_selectedCategory',
                      onRemove: () => setState(() => _selectedCategory = 'همه'),
                    ),
                  if (_selectedStatus != 'همه' || _selectedCategory != 'همه')
                    _buildFilterChip(
                      label: 'پاک کردن همه',
                      onRemove: () => setState(() {
                        _selectedStatus = 'همه';
                        _selectedCategory = 'همه';
                      }),
                      isClear: true,
                    ),
                ],
              ),
            ),

          // آمار سریع
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _statChip('همه', _filteredNotifications.length, Colors.grey),
                const SizedBox(width: 6),
                _statChip(
                  'در انتظار',
                  provider.getByStatus(NotificationStatus.pending).length,
                  Colors.orange,
                ),
                const SizedBox(width: 6),
                _statChip(
                  'دیده شده',
                  provider.getByStatus(NotificationStatus.shown).length,
                  Colors.green,
                ),
                const SizedBox(width: 6),
                _statChip(
                  'منقضی',
                  provider.getByStatus(NotificationStatus.expired).length,
                  Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // لیست اعلان‌ها
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty || _selectedStatus != 'همه' || _selectedCategory != 'همه'
                              ? 'نتیجه‌ای یافت نشد'
                              : 'هیچ اعلانی وجود ندارد',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedStatus != 'همه' || _selectedCategory != 'همه'
                              ? 'فیلترهای خود را تغییر دهید'
                              : 'با دکمه + یک اعلان جدید اضافه کنید',
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
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return NotificationCard(
                        notification: notif,
                        onTap: () {
                          // رفتن به صفحه ویرایش
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddNotificationScreen(
                                notification: notif,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        onDismiss: () {
                          // تغییر وضعیت به بسته شده
                          provider.changeStatus(notif.id, NotificationStatus.dismissed);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ اعلان "${notif.title}" بسته شد'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        onDelete: () {
                          _confirmDelete(context, notif);
                        },
                      );
                    },
                  ),
          ),

          // صفحه‌بندی
          if (_filteredNotifications.length > _pageSize)
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
                    'کل: ${_filteredNotifications.length}',
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
              builder: (_) => const AddNotificationScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    bool isClear = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isClear ? Colors.red.shade100 : const Color(0xFF6C5CE7).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isClear ? Colors.red.shade300 : const Color(0xFF6C5CE7).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isClear ? Colors.red.shade700 : const Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: isClear ? Colors.red.shade700 : const Color(0xFF6C5CE7),
            ),
          ),
        ],
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('جستجو در اعلان‌ها'),
        content: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'عنوان یا متن اعلان...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(ctx);
            },
            child: const Text('پاک کردن'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(List<String> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'فیلترها',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            // فیلتر وضعیت
            _buildFilterRow(
              label: 'وضعیت',
              options: _statusOptions,
              selected: _selectedStatus,
              onSelected: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
            const SizedBox(height: 12),
            // فیلتر دسته‌بندی
            _buildFilterRow(
              label: 'دسته‌بندی',
              options: categories,
              selected: _selectedCategory,
              onSelected: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = 'همه';
                        _selectedCategory = 'همه';
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('پاک کردن همه'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('اعمال'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow({
    required String label,
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((option) {
            final isSelected = option == selected;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelected(option);
              },
              selectedColor: const Color(0xFF6C5CE7),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, AppNotification notification) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف اعلان'),
        content: Text('آیا از حذف اعلان "${notification.title}" مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              final provider = context.read<NotificationProvider>();
              provider.deleteNotification(notification.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ اعلان "${notification.title}" حذف شد'),
                  duration: const Duration(seconds: 2),
                ),
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