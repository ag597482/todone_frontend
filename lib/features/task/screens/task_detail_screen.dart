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
  final TaskService _taskService = TaskService();
  bool isTaskCompleted = false;

  TaskModel? _task;
  bool _loading = true;
  String? _error;
  int? _togglingStepIndex;
  bool _markingComplete = false;

  // Edit mode state
  bool _isEditing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final List<TextEditingController> _stepControllers = [];
  final List<bool> _stepCompleted = [];
  bool _savingEdits = false;

  @override
  void initState() {
    super.initState();
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
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleStep(int index) async {
    final task = _task;
    if (task == null || widget.taskId == null || widget.userId == null) return;
    if (index < 0 || index >= task.steps.length) return;
    final step = task.steps[index];
    final newCompleted = !step.completed;
    setState(() => _togglingStepIndex = index);
    final result = await _taskService.updateSubtaskStatus(
      widget.taskId!,
      widget.userId!,
      step.value,
      newCompleted,
    );
    if (!mounted) return;
    setState(() => _togglingStepIndex = null);
    switch (result) {
      case ApiSuccess(data: final updatedTask):
        setState(() => _task = updatedTask);
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  Future<void> _markTaskCompleted() async {
    if (widget.taskId == null || widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot complete task')),
      );
      return;
    }
    setState(() => _markingComplete = true);
    final result = await _taskService.updateTaskStatus(
      widget.taskId!,
      widget.userId!,
      'COMPLETED',
    );
    if (!mounted) return;
    setState(() => _markingComplete = false);
    switch (result) {
      case ApiSuccess(data: final updatedTask):
        setState(() {
          isTaskCompleted = true;
          _task = updatedTask;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.taskCompleted)),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  Future<void> _markTaskPending() async {
    if (widget.taskId == null || widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update task status')),
      );
      return;
    }
    setState(() => _markingComplete = true);
    final result = await _taskService.updateTaskStatus(
      widget.taskId!,
      widget.userId!,
      'PENDING',
    );
    if (!mounted) return;
    setState(() => _markingComplete = false);
    switch (result) {
      case ApiSuccess(data: final updatedTask):
        setState(() {
          isTaskCompleted = false;
          _task = updatedTask;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as pending')),
        );
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  String get _title => _task?.title ?? widget.taskTitle;
  String get _description => _task?.description ?? widget.taskDescription;
  String get _category => _task?.displayLabel ?? widget.category;
  String get _dueDate => _task?.dueDate ?? widget.dueDate;
  String get _reminderTime => _task?.timeDisplay ?? widget.reminderTime;

  void _enterEditMode() {
    final task = _task;
    if (task == null || widget.userId == null) {
      return;
    }

    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _timeController.text = task.reminderTime ?? '';

    for (final c in _stepControllers) {
      c.dispose();
    }
    _stepControllers.clear();
    _stepCompleted.clear();

    for (final step in task.steps) {
      final c = TextEditingController(text: step.value);
      _stepControllers.add(c);
      _stepCompleted.add(step.completed);
    }

    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    for (final c in _stepControllers) {
      c.dispose();
    }
    _stepControllers.clear();
    _stepCompleted.clear();
    setState(() {
      _isEditing = false;
      _savingEdits = false;
    });
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _stepCompleted.add(false);
    });
  }

  void _removeStepField(int index) {
    if (index < 0 || index >= _stepControllers.length) return;
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
      _stepCompleted.removeAt(index);
    });
  }

  Future<void> _saveEdits() async {
    final task = _task;
    final userId = widget.userId;
    final taskId = widget.taskId;
    if (task == null || userId == null || taskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update task')),
      );
      return;
    }
    final name = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task name cannot be empty')),
      );
      return;
    }

    final steps = <SubtaskStep>[];
    for (var i = 0; i < _stepControllers.length; i++) {
      final value = _stepControllers[i].text.trim();
      if (value.isEmpty) continue;
      steps.add(SubtaskStep(value, _stepCompleted[i]));
    }

    setState(() {
      _savingEdits = true;
    });

    final timeStr = _timeController.text.trim();
    final result = await _taskService.updateTaskFull(
      taskId: task.id,
      userId: userId,
      name: name,
      description: description,
      steps: steps,
      dueDate: task.dueDate,
      doneDate: null,
      status: task.status,
      authorId: userId,
      time: timeStr.isNotEmpty ? timeStr : null,
    );

    if (!mounted) return;

    setState(() {
      _savingEdits = false;
    });

    switch (result) {
      case ApiSuccess(data: final updatedTask):
        setState(() {
          _task = updatedTask;
          isTaskCompleted = updatedTask.status == 'COMPLETED';
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated')),
        );
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

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
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: widget.userId != null && _task != null ? _enterEditMode : null,
            ),
          if (_isEditing)
            TextButton(
              onPressed: _savingEdits ? null : _cancelEdit,
              child: const Text(AppStrings.cancel),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _savingEdits ? null : _saveEdits,
              child: _savingEdits
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.save),
            ),
          if (!_isEditing)
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
                              _isEditing
                                  ? TextField(
                                      controller: _titleController,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Task name',
                                      ),
                                    )
                                  : Text(
                                      _title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              const SizedBox(height: 16),

                              // Task Description
                              _isEditing
                                  ? TextField(
                                      controller: _descriptionController,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Description',
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF475569),
                                        height: 1.5,
                                      ),
                                    )
                                  : Text(
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
                                    _isEditing
                                        ? SizedBox(
                                            width: 80,
                                            child: TextField(
                                              controller: _timeController,
                                              decoration: InputDecoration(
                                                hintText: '14:30',
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                border: const OutlineInputBorder(),
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? const Color(0xFFE2E8F0)
                                                    : const Color(0xFF1E293B),
                                              ),
                                              keyboardType: TextInputType.datetime,
                                            ),
                                          )
                                        : Text(
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

            // AI Generated Steps Section (from API meta.steps, toggle via PUT subtask-status)
            if ((_task?.steps.isNotEmpty ?? false) || _isEditing) ...[
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
                    const SizedBox(height: 8),
                    // Progress bar: 0–100% based on completed subtasks
                    Builder(
                      builder: (context) {
                        final total = _task!.steps.length;
                        final completed = _task!.steps.where((s) => s.completed).length;
                        final progress = total > 0 ? completed / total : 0.0;
                        final percent = (progress * 100).round();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$completed of $total completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  '$percent%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                              ),
                            ),
                          ],
                        );
                      },
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
                        itemCount: _isEditing ? _stepControllers.length : _task!.steps.length,
                        itemBuilder: (context, index) {
                          if (_isEditing) {
                            final controller = _stepControllers[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: index != _stepControllers.length - 1
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
                                    value: _stepCompleted[index],
                                    onChanged: (value) {
                                      setState(() {
                                        _stepCompleted[index] = value ?? false;
                                      });
                                    },
                                    fillColor: MaterialStateProperty.resolveWith(
                                      (states) {
                                        if (states.contains(MaterialState.selected)) {
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
                                    child: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Subtask',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    onPressed: () => _removeStepField(index),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            final step = _task!.steps[index];
                            final isToggling = _togglingStepIndex == index;

                            return GestureDetector(
                              onTap: isToggling ? null : () => _toggleStep(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: index != _task!.steps.length - 1
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
                                    if (isToggling)
                                      const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    else
                                      Checkbox(
                                        value: step.completed,
                                        onChanged: widget.userId != null
                                            ? (_) => _toggleStep(index)
                                            : null,
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
                                        step.value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          decoration: step.completed
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: step.completed
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
                          }
                        },
                      ),
                    ),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addStepField,
                            icon: const Icon(Icons.add),
                            label: const Text('Add subtask'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Mark Task Completed Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _markingComplete
                      ? null
                      : (isTaskCompleted ? _markTaskPending : _markTaskCompleted),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _markingComplete
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isTaskCompleted
                                  ? Icons.refresh
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isTaskCompleted
                                  ? 'Mark Task Pending'
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
