import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';
import 'package:todone_frontend/routes/index.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskTitle;
  final String taskDescription;
  final String category;
  final String dueDate;
  final String reminderTime;
  final String? taskId;
  final String? userId;

  const TaskDetailScreen({
    super.key,
    required this.taskTitle,
    required this.taskDescription,
    required this.category,
    required this.dueDate,
    required this.reminderTime,
    this.taskId,
    this.userId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _progressController = TextEditingController();
  final TaskService _taskService = TaskService();
  late List<Map<String, dynamic>> steps;
  bool isTaskCompleted = false;

  TaskModel? _task;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    steps = [
      {'title': 'Buy gym clothes', 'completed': false},
      {'title': 'Find nearby gym', 'completed': false},
      {'title': 'Pack your gym bag tonight', 'completed': false},
    ];
    if (widget.taskId != null) {
      _fetchTask();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchTask() async {
    if (widget.taskId == null) return;
    final result = await _taskService.getTask(widget.taskId!);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: final task):
        setState(() {
          _task = task;
          _loading = false;
          _error = null;
          isTaskCompleted = task.status == 'COMPLETED';
        });
      case ApiFailure(message: final message):
        setState(() {
          _task = null;
          _loading = false;
          _error = message;
        });
    }
  }

  Future<void> _deleteTask() async {
    if (widget.taskId == null || widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.cannotDeleteTask)),
      );
      return;
    }
    final result = await _taskService.deleteTask(widget.taskId!, widget.userId!);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.dashboard,
          (route) => false,
        );
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  void _showDeleteConfirm() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text(AppStrings.deleteTaskConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTask();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _toggleStep(int index) {
    setState(() {
      steps[index]['completed'] = !steps[index]['completed'];
    });
  }

  void _submitProgress() {
    if (_progressController.text.isNotEmpty) {
      // TODO: Handle progress update submission
      _progressController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress updated')),
      );
    }
  }

  void _markTaskCompleted() {
    setState(() {
      isTaskCompleted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task marked as completed')),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  String get _title => _task?.title ?? widget.taskTitle;
  String get _description => _task?.description ?? widget.taskDescription;
  String get _category => _task?.displayLabel ?? widget.category;
  String get _dueDate => _task?.dueDate ?? widget.dueDate;
  String get _reminderTime => _task?.timeDisplay ?? widget.reminderTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A).withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(AppStrings.taskDetail),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') _showDeleteConfirm();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 22),
                    SizedBox(width: 12),
                    Text(AppStrings.deleteTask),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Task Info Card
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Badge
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  _category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Task Title
                              Text(
                                _title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Task Description
                              Text(
                                _description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Meta Info (Due Date & Reminder)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${AppStrings.due}: $_dueDate',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Icon(
                                      Icons.notifications_active,
                                      size: 16,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${AppStrings.daily} $_reminderTime',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

            // AI Generated Steps Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF4F46E5),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.aiGeneratedSteps,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: steps.length,
                      itemBuilder: (context, index) {
                        final step = steps[index];
                        final isCompleted = step['completed'] as bool;

                        return GestureDetector(
                          onTap: () => _toggleStep(index),
                          child: Container(
                            decoration: BoxDecoration(
                              border: index != steps.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    )
                                  : null,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isCompleted,
                                  onChanged: (_) => _toggleStep(index),
                                  fillColor: MaterialStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return const Color(0xFF4F46E5);
                                      }
                                      return Colors.transparent;
                                    },
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    step['title'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isCompleted
                                          ? (isDark
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFFA0AEC0))
                                          : (isDark
                                              ? const Color(0xFFE2E8F0)
                                              : const Color(0xFF1E293B)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Suggestion Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4F46E5).withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        AppStrings.aiSuggestion,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _progressController,
                        decoration: InputDecoration(
                          hintText: AppStrings.addProgressUpdate,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFFA0AEC0),
                          ),
                        ),
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF4F46E5),
                        ),
                        onPressed: _submitProgress,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mark Task Completed Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isTaskCompleted ? null : _markTaskCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isTaskCompleted ? Icons.check_circle : Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTaskCompleted
                            ? AppStrings.taskCompleted
                            : AppStrings.markTaskCompleted,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
