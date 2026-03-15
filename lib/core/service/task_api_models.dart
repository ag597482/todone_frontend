import 'package:flutter/material.dart';

/// Task model from GET /api/tasks/user/{userId} response (data list item).
class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.reminderTime,
    this.status,
    this.hasAISteps = false,
    this.hasNotes = false,
  });

  final String id;
  final String title;
  final String description;
  final String? dueDate;
  final String? reminderTime;
  final String? status;
  final bool hasAISteps;
  final bool hasNotes;

  static TaskModel fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map);
    return TaskModel(
      id: map['task_id']?.toString() ?? map['id']?.toString() ?? '',
      title: map['name'] as String? ?? map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: map['dueDate']?.toString() ?? map['due_date']?.toString(),
      reminderTime: map['reminderTime']?.toString() ?? map['reminder_time']?.toString() ?? map['time']?.toString(),
      status: map['status']?.toString() ?? map['label']?.toString() ?? map['category']?.toString(),
      hasAISteps: map['hasAISteps'] == true || map['has_ai_steps'] == true,
      hasNotes: map['hasNotes'] == true ||
          map['has_notes'] == true ||
          (map['meta'] is Map && (map['meta'] as Map).isNotEmpty) ||
          (map['notes'] != null && map['notes'].toString().isNotEmpty),
    );
  }

  /// Label for TaskCard (e.g. "Due Today", "Rolled Over").
  String get displayLabel => status?.isNotEmpty == true ? status! : 'Task';

  /// Color for label chip from status.
  Color get labelColor {
    final s = (status ?? '').toLowerCase();
    if (s.contains('due') || s.contains('today')) return const Color(0xFF4F46E5);
    if (s.contains('roll') || s.contains('over')) return const Color(0xFFA16207);
    if (s.contains('miss')) return const Color(0xFFDC2626);
    return const Color(0xFF4F46E5);
  }

  Color get labelBgColor {
    final s = (status ?? '').toLowerCase();
    if (s.contains('due') || s.contains('today')) return Color(0xFF4F46E5).withOpacity(0.1);
    if (s.contains('roll') || s.contains('over')) return const Color(0xFFFEF3C7);
    if (s.contains('miss')) return Color(0xFFDC2626).withOpacity(0.1);
    return Color(0xFF4F46E5).withOpacity(0.1);
  }

  /// Display time or formatted due date when no reminder time (API has dueDate only).
  String get timeDisplay {
    if (reminderTime != null && reminderTime!.isNotEmpty) return reminderTime!;
    if (dueDate != null && dueDate!.isNotEmpty) {
      try {
        final d = DateTime.parse(dueDate!);
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[d.month - 1]} ${d.day}';
      } catch (_) {}
    }
    return '--';
  }
}
