import 'package:flutter/material.dart';

enum TaskStatus { done, missed }

class TaskHistoryItem extends StatelessWidget {
  final String title;
  final String date;
  final TaskStatus status;

  const TaskHistoryItem({
    super.key,
    required this.title,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDone = status == TaskStatus.done;
    final iconColor = isDone ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bgColor = isDone
        ? const Color(0xFFF0FDF4)
        : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? bgColor.withOpacity(0.3) : bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDone ? Icons.task_alt : Icons.close,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? (isDone ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D))
                  : (isDone
                      ? const Color(0xFFE6F4EA)
                      : const Color(0xFFFCE7E7)),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              isDone ? 'Done' : 'Missed',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDone ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
