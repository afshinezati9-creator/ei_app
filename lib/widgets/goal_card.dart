// ============================================================
// مسیر: lib/widgets/goal_card.dart (کامل با پشتیبانی از onTap پیش‌فرض)
// ============================================================
import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../screens/goal_detail_screen.dart'; // برای هدایت به صفحه جزئیات

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;          // اگر null باشد، پیش‌فرض به صفحه جزئیات می‌رود
  final VoidCallback? onLongPress;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _hexToColor(goal.color);

    return GestureDetector(
      onTap: onTap ?? () {
        // اگر onTap تعریف نشده باشد، به صفحه جزئیات هدف برو
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GoalDetailScreen(goalId: goal.id),
          ),
        );
      },
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: goal.isCompleted ? Colors.green.shade300 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== ردیف اول: عنوان، وضعیت و اولویت =====
            Row(
              children: [
                // نوار رنگی کنار کارت
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // نشان‌دهنده وضعیت
                _buildStatusChip(),
                const SizedBox(width: 6),
                // نشان‌دهنده اولویت
                _buildPriorityChip(),
              ],
            ),
            const SizedBox(height: 8),

            // ===== توضیحات =====
            if (goal.description.isNotEmpty)
              Text(
                goal.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (goal.description.isNotEmpty) const SizedBox(height: 6),

            // ===== نوار پیشرفت =====
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${goal.progressPercent}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF6C5CE7),
                            ),
                          ),
                          Text(
                            '${_formatNumber(goal.currentAmount)} / ${_formatNumber(goal.targetAmount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          backgroundColor: Colors.grey.shade200,
                          color: goal.isCompleted ? Colors.green : color,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ===== اطلاعات پایین کارت =====
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  'سررسید: ${goal.deadline}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.timeline,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  'باقی‌مانده: ${_formatNumber(goal.remainingAmount)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                if (goal.note != null && goal.note!.isNotEmpty)
                  Icon(
                    Icons.note_alt_outlined,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== ویجت وضعیت =====
  Widget _buildStatusChip() {
    Color color;
    String label;

    switch (goal.status) {
      case GoalStatus.inProgress:
        color = Colors.orange;
        label = 'در حال انجام';
        break;
      case GoalStatus.completed:
        color = Colors.green;
        label = '✅ تکمیل شده';
        break;
      case GoalStatus.cancelled:
        color = Colors.red;
        label = 'لغو شده';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ===== ویجت اولویت =====
  Widget _buildPriorityChip() {
    Color color = goal.priorityColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
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
          const SizedBox(width: 3),
          Text(
            goal.priorityLabel,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===== تبدیل رنگ Hex به Color =====
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  // ===== فرمت اعداد با کاما =====
  String _formatNumber(double value) {
    final number = value.toInt();
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}