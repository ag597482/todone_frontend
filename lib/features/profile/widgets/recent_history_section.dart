import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/api_result.dart';
import 'package:todone_frontend/core/service/task_api_models.dart';
import 'package:todone_frontend/core/service/task_service.dart';
import 'package:todone_frontend/core/service/user_storage_service.dart';
import 'task_history_item.dart';

/// Fetches tasks from GET /api/tasks/user/{userId} (no date filter) and displays them in Recent History.
class RecentHistorySection extends StatefulWidget {
  const RecentHistorySection({super.key});

  @override
  State<RecentHistorySection> createState() => _RecentHistorySectionState();
}

class _RecentHistorySectionState extends State<RecentHistorySection> {
  final TaskService _taskService = TaskService();
  final UserStorageService _userStorage = UserStorageService();

  List<TaskModel> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final user = await _userStorage.getUser();
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _tasks = [];
        _loading = false;
        _error = 'Please log in again';
      });
      return;
    }
    final result = await _taskService.getTasksForUser(user.userId);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: final list):
        setState(() {
          _tasks = list;
          _loading = false;
          _error = null;
        });
      case ApiFailure(message: final message):
        setState(() {
          _tasks = [];
          _loading = false;
          _error = message;
        });
    }
  }

  static String _formatTaskDate(String? dueDate) {
    if (dueDate == null || dueDate.isEmpty) return '--';
    try {
      final d = DateTime.parse(dueDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final taskDay = DateTime(d.year, d.month, d.day);
      if (taskDay == today) return 'Today';
      if (taskDay == yesterday) return 'Yesterday';
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return dueDate;
    }
  }

  static TaskStatus _statusFromApi(String? status) {
    if (status == null) return TaskStatus.missed;
    if (status.toUpperCase() == 'COMPLETED') return TaskStatus.done;
    return TaskStatus.missed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentHistory,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: View all tasks
              },
              child: Text(
                AppStrings.viewAll,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else if (_tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                AppStrings.taskHistoryEmpty,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          )
        else
          ...List.generate(_tasks.length, (i) {
            final task = _tasks[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _tasks.length - 1 ? 8 : 0),
              child: TaskHistoryItem(
                title: task.title,
                date: _formatTaskDate(task.dueDate),
                status: _statusFromApi(task.status),
              ),
            );
          }),
      ],
    );
  }
}
