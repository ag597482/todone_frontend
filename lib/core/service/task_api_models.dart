import 'package:flutter/material.dart';

/// A single subtask/step from API meta.steps (value + completed).
class SubtaskStep {
  const SubtaskStep(this.value, this.completed);
  final String value;
  final bool completed;
}

/// Task model from GET /api/tasks/user/{userId} and POST /api/tasks response (data).
/// Supports meta.steps from API as list of strings or list of { value, completed }.
class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.reminderTime,
    this.status,
    this.taskGroupId,
    List<SubtaskStep>? steps,
    bool? hasAISteps,
    this.hasNotes = false,
  })  : steps = steps ?? const [],
        hasAISteps = hasAISteps ?? (steps?.isNotEmpty ?? false);

  final String id;
  final String title;
  final String description;
  final String? dueDate;
  final String? reminderTime;
  final String? status;
  /// Optional task group / parent grouping id from API.
  final String? taskGroupId;
  /// AI-generated steps from API response meta.steps (value + completed).
  final List<SubtaskStep> steps;
  final bool hasAISteps;
  final bool hasNotes;

  /// Parses meta.steps from API: either ["step1", "step2"] or [{ "value": "...", "completed": bool }].
  /// Handles empty meta ({}) or missing meta/steps (e.g. task create response with meta: {}).
  static List<SubtaskStep> _parseSteps(dynamic json) {
    if (json == null) return [];
    final map = json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map);
    final meta = map['meta'];
    if (meta == null || meta is! Map) return [];
    final s = meta['steps'];
    if (s == null || s is! List) return [];
    final result = <SubtaskStep>[];
    for (final e in s) {
      if (e is String && e.isNotEmpty) {
        result.add(SubtaskStep(e, false));
      } else if (e is Map) {
        final m = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e);
        final value = (m['value'] ?? m['title'] ?? '').toString().trim();
        if (value.isEmpty) continue;
        final completed = m['completed'] == true;
        result.add(SubtaskStep(value, completed));
      }
    }
    return result;
  }

  static TaskModel fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map);
    final stepsList = _parseSteps(map);
    String? reminder;
    // Prefer explicit reminder fields, then top-level time, then meta.time
    if (map['reminderTime'] != null) {
      reminder = map['reminderTime'].toString();
    } else if (map['reminder_time'] != null) {
      reminder = map['reminder_time'].toString();
    } else if (map['time'] != null) {
      reminder = map['time'].toString();
    } else if (map['meta'] is Map && (map['meta'] as Map)['time'] != null) {
      reminder = (map['meta'] as Map)['time'].toString();
    }
    final rawGroupId = map['task_group_id'] ?? map['taskGroupId'] ?? map['task_groupId'];
    final groupIdStr = rawGroupId?.toString();
    final taskGroupId =
        groupIdStr != null && groupIdStr.isNotEmpty ? groupIdStr : null;

    return TaskModel(
      id: map['task_id']?.toString() ?? map['id']?.toString() ?? '',
      title: map['name'] as String? ?? map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: map['dueDate']?.toString() ?? map['due_date']?.toString(),
      reminderTime: reminder,
      status: map['status']?.toString() ?? map['label']?.toString() ?? map['category']?.toString(),
      taskGroupId: taskGroupId,
      steps: stepsList,
      hasAISteps: map['hasAISteps'] == true ||
          map['has_ai_steps'] == true ||
          stepsList.isNotEmpty,
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

  /// Combined DateTime for sorting: uses dueDate + reminderTime (HH:mm) when available.
  /// Falls back to dueDate at midnight; returns null if parsing fails.
  DateTime? get sortDateTime {
    if (dueDate == null || dueDate!.isEmpty) return null;
    try {
      final baseDate = DateTime.parse(dueDate!);
      if (reminderTime == null || reminderTime!.isEmpty) {
        return DateTime(baseDate.year, baseDate.month, baseDate.day);
      }
      final parts = reminderTime!.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
      }
      return DateTime(baseDate.year, baseDate.month, baseDate.day);
    } catch (_) {
      return null;
    }
  }
}
