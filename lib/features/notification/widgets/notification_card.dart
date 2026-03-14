import 'package:flutter/material.dart';

enum NotificationStatus { dueSoon, missed, rolledOver, new_ }

class NotificationCard extends StatelessWidget {
  final String title;
  final String taskType; // "One-time Task" or "Routine"
  final String time;
  final NotificationStatus status;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback? onDismiss;

  const NotificationCard({
    super.key,
    required this.title,
    required this.taskType,
    required this.time,
    required this.status,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.onDismiss,
  });

  String _getStatusLabel() {
    switch (status) {
      case NotificationStatus.dueSoon:
        return 'DUE SOON';
      case NotificationStatus.missed:
        return 'MISSED';
      case NotificationStatus.rolledOver:
        return 'ROLLED OVER';
      case NotificationStatus.new_:
        return 'NEW';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case NotificationStatus.dueSoon:
        return const Color(0xFFA16207);
      case NotificationStatus.missed:
        return const Color(0xFFBE123C);
      case NotificationStatus.rolledOver:
        return const Color(0xFF64748B);
      case NotificationStatus.new_:
        return const Color(0xFF4F46E5);
    }
  }

  Color _getStatusBgColor() {
    switch (status) {
      case NotificationStatus.dueSoon:
        return const Color(0xFFFEF3C7);
      case NotificationStatus.missed:
        return const Color(0xFFFFE4E6);
      case NotificationStatus.rolledOver:
        return const Color(0xFFF1F5F9);
      case NotificationStatus.new_:
        return const Color(0xFFEEF2FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? iconBgColor.withOpacity(0.2)
                  : iconBgColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
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
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                            ? _getStatusColor().withOpacity(0.2)
                            : _getStatusBgColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        _getStatusLabel(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      taskType == 'Routine' ? Icons.sync : Icons.event,
                      size: 14,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      taskType,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.alarm,
                      size: 14,
                      color: const Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
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
    );
  }
}
