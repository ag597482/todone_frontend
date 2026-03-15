import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';
import 'package:todone_frontend/routes/index.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String description;
  final String label;
  final Color labelColor;
  final Color labelBgColor;
  final String time;
  final bool hasAISteps;
  final bool hasNotes;
  final String? dueDate;
  final String? taskId;
  final String? userId;
  final bool initialChecked;
  final VoidCallback? onStatusChanged;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.label,
    required this.labelColor,
    required this.labelBgColor,
    required this.time,
    this.hasAISteps = true,
    this.hasNotes = false,
    this.dueDate,
    this.taskId,
    this.userId,
    this.initialChecked = false,
    this.onStatusChanged,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool isChecked;
  bool _updating = false;
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialChecked;
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialChecked != widget.initialChecked) {
      isChecked = widget.initialChecked;
    }
  }

  Future<void> _onCheckChanged(bool? value) async {
    final newValue = value ?? false;
    if (widget.taskId == null || widget.userId == null) {
      setState(() => isChecked = newValue);
      return;
    }

    setState(() {
      isChecked = newValue;
      _updating = true;
    });

    final status = newValue ? 'COMPLETED' : 'PENDING';
    final result = await _taskService.updateTaskStatus(
      widget.taskId!,
      widget.userId!,
      status,
    );

    if (!mounted) return;
    setState(() => _updating = false);

    switch (result) {
      case ApiSuccess():
        widget.onStatusChanged?.call();
      case ApiFailure(message: final message):
        setState(() => isChecked = !newValue);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  void _openTaskDetail(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.taskDetail,
      arguments: TaskDetailArgs(
        taskTitle: widget.title,
        taskDescription: widget.description,
        category: widget.label,
        dueDate: widget.dueDate ?? 'Oct 20',
        reminderTime: widget.time,
        taskId: widget.taskId,
        userId: widget.userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(12),
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isChecked,
                onChanged: _updating ? null : _onCheckChanged,
                activeColor: const Color(0xFF4F46E5),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openTaskDetail(context),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: widget.labelBgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: widget.labelColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
              children: [
                if (widget.hasAISteps)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.aiSteps,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.hasNotes)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.notes,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: const Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
  }
}
