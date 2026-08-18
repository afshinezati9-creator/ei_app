// ============================================================
// مسیر: lib/widgets/notification_dialog.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/notification.dart';
import '../screens/notifications_screen.dart';

class NotificationDialog extends StatefulWidget {
  final List<AppNotification> notifications;

  const NotificationDialog({super.key, required this.notifications});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  List<String> _dismissedIds = [];

  @override
  Widget build(BuildContext context) {
    final remaining = widget.notifications.where(
      (n) => !_dismissedIds.contains(n.id)
    ).toList();

    if (remaining.isEmpty) {
      // اگر همه بسته شدند، دیالوگ را ببند
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.notifications_active, color: Color(0xFF6C5CE7)),
          const SizedBox(width: 8),
          const Text('اعلان‌های جدید'),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: remaining.length,
          itemBuilder: (context, index) {
            final notification = remaining[index];
            return _buildNotificationItem(notification);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // بستن همه اعلان‌ها (تغییر وضعیت به dismissed)
            for (var n in widget.notifications) {
              if (!_dismissedIds.contains(n.id)) {
                context.read<NotificationProvider>().changeStatus(
                  n.id,
                  NotificationStatus.dismissed,
                );
              }
            }
            Navigator.pop(context);
          },
          child: const Text('بستن همه'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
          child: const Text(
            'مشاهده همه',
            style: TextStyle(color: Color(0xFF6C5CE7)),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(notification.priorityColor).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // نشان اولویت
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: Color(notification.priorityColor),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),

          // محتوا
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Color(notification.priorityColor).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        notification.priorityLabel,
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(notification.priorityColor),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text(
                      '${notification.scheduledDate} ${notification.scheduledTime}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.label, size: 10, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text(
                      notification.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // دکمه بستن
          GestureDetector(
            onTap: () {
              setState(() {
                _dismissedIds.add(notification.id);
              });
              // تغییر وضعیت به dismissed
              context.read<NotificationProvider>().changeStatus(
                notification.id,
                NotificationStatus.dismissed,
              );
            },
            child: Icon(
              Icons.close,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}