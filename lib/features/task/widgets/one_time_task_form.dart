import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';

/// Callback: (taskName, taskDescription) -> list of step strings or null on error.
typedef GenerateStepsCallback = Future<List<String>?> Function(
  String taskName,
  String taskDescription,
);

class OneTimeTaskForm extends StatefulWidget {
  const OneTimeTaskForm({
    super.key,
    this.onGenerateAISteps,
  });

  final GenerateStepsCallback? onGenerateAISteps;

  @override
  State<OneTimeTaskForm> createState() => OneTimeTaskFormState();
}

class OneTimeTaskFormState extends State<OneTimeTaskForm> {
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesControllers = <TextEditingController>[];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _generatingSteps = false;

  /// Returns task payload for API: name, description, dueDate (yyyy-MM-dd), time (HH:mm), meta.steps (if any), or null if invalid.
  Map<String, dynamic>? getTaskPayload() {
    final name = _taskNameController.text.trim();
    if (name.isEmpty || _selectedDate == null) return null;
    final d = _selectedDate!;
    final dueDate =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final steps = <Map<String, dynamic>>[];
    for (var i = 0; i < _notesControllers.length; i++) {
      final value = _notesControllers[i].text.trim();
      if (value.isNotEmpty) {
        steps.add({'value': value, 'completed': false});
      }
    }
    final payload = <String, dynamic>{
      'name': name,
      'description': _descriptionController.text.trim(),
      'dueDate': dueDate,
    };
    if (_selectedTime != null) {
      final t = _selectedTime!;
      payload['time'] =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    if (steps.isNotEmpty) {
      payload['meta'] = {'steps': steps};
    }
    return payload;
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    for (var controller in _notesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNoteField() {
    setState(() {
      _notesControllers.add(TextEditingController());
    });
  }

  void _removeNoteField(int index) {
    setState(() {
      _notesControllers[index].dispose();
      _notesControllers.removeAt(index);
    });
  }

  /// Populates subtask fields with [steps] (editable). Disposes existing controllers.
  void setGeneratedSteps(List<String> steps) {
    for (final c in _notesControllers) {
      c.dispose();
    }
    _notesControllers.clear();
    for (final step in steps) {
      _notesControllers.add(TextEditingController(text: step));
    }
    setState(() {});
  }

  Future<void> _onGenerateAISteps() async {
    final callback = widget.onGenerateAISteps;
    if (callback == null) return;
    final name = _taskNameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a task name to generate steps')),
        );
      }
      return;
    }
    setState(() => _generatingSteps = true);
    final steps = await callback(name, _descriptionController.text.trim());
    if (!mounted) return;
    setState(() => _generatingSteps = false);
    if (steps != null && steps.isNotEmpty) {
      setGeneratedSteps(steps);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI steps added. You can edit them below.')),
      );
    } else if (steps != null && steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No steps returned. Try again.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate steps. Try again.')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.taskName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  hintText: AppStrings.taskNamePlaceholder,
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4F46E5),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.description,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppStrings.descriptionPlaceholder,
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4F46E5),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Date & Time Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.dueDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                                  : 'Select date',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedDate != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.reminder,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              size: 18,
                              color: const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : 'Select time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedTime != null
                                      ? (isDark ? Colors.white : Colors.black)
                                      : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // AI Steps Generator
          GestureDetector(
            onTap: _generatingSteps ? null : _onGenerateAISteps,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF4F46E5).withOpacity(0.05),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_generatingSteps)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                      ),
                    )
                  else
                    Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFF4F46E5),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _generatingSteps ? 'Generating…' : AppStrings.generateAISteps,
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Subtasks Section (sent as meta.steps in POST /api/tasks)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.subtasksLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      letterSpacing: 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: _addNoteField,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          size: 16,
                          color: const Color(0xFF4F46E5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.addSubtask,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notesControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _notesControllers[index],
                            decoration: InputDecoration(
                              hintText: AppStrings.subtaskHint,
                              border: InputBorder.none,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF4F46E5),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _removeNoteField(index),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
