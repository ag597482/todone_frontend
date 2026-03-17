import 'package:flutter/material.dart';
import 'package:todone_frontend/core/service/notification_api_models.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _expanded = false;

  static String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--';
    try {
      final d = DateTime.parse(timeStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final t = DateTime(d.year, d.month, d.day);
      final timePart =
          '${d.hour > 12 ? d.hour - 12 : d.hour == 0 ? 12 : d.hour}:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
      if (t == today) return 'Today $timePart';
      if (t == yesterday) return 'Yesterday $timePart';
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[d.month - 1]} ${d.day}, $timePart';
    } catch (_) {
      return timeStr;
    }
  }

  Color _statusColor(bool isDark) {
    final s = widget.notification.status.toUpperCase();
    if (s == 'READ') {
      return const Color(0xFF4F46E5);
    }
    return const Color(0xFF64748B);
  }

  Color _statusBgColor(bool isDark) {
    final s = widget.notification.status.toUpperCase();
    if (s == 'READ') {
      return isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF);
    }
    return isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = widget.notification.status.toUpperCase();
    final statusLabel = status.isEmpty ? '--' : status;
    final iconColor = status == 'READ'
        ? const Color(0xFF4F46E5)
        : const Color(0xFF64748B);
    final iconBgColor = status == 'READ'
        ? (isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF))
        : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? iconBgColor.withOpacity(0.5)
                    : iconBgColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                status == 'READ' ? Icons.done_all : Icons.notifications,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.notification.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? _statusColor(isDark).withOpacity(0.2)
                              : _statusBgColor(isDark),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(isDark),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.notification.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: _expanded ? null : 2,
                      overflow:
                          _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: const Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(widget.notification.time),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
