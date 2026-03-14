import 'package:flutter/material.dart';
import 'package:todone_frontend/features/auth/screens/index.dart';
import 'package:todone_frontend/features/dashboard/screens/index.dart';
import 'package:todone_frontend/features/notification/screens/index.dart';
import 'package:todone_frontend/features/profile/screens/index.dart';
import 'package:todone_frontend/features/settings/screens/index.dart';
import 'package:todone_frontend/features/task/screens/index.dart';

/// Arguments for navigating to [TaskDetailScreen].
class TaskDetailArgs {
  final String taskTitle;
  final String taskDescription;
  final String category;
  final String dueDate;
  final String reminderTime;

  const TaskDetailArgs({
    required this.taskTitle,
    required this.taskDescription,
    required this.category,
    required this.dueDate,
    required this.reminderTime,
  });
}

abstract class AppRoutes {
  AppRoutes._();

  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String createTask = '/create-task';
  static const String notification = '/notification';
  static const String profile = '/profile';
  static const String taskDetail = '/task-detail';
  static const String baseUrlSettings = '/settings/base-url';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AuthScreen(),
        );
      case dashboard:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DashboardScreen(),
        );
      case createTask:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CreateTaskScreen(),
        );
      case notification:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const NotificationScreen(),
        );
      case profile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      case taskDetail:
        final args = settings.arguments as TaskDetailArgs?;
        if (args == null) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => TaskDetailScreen(
            taskTitle: args.taskTitle,
            taskDescription: args.taskDescription,
            category: args.category,
            dueDate: args.dueDate,
            reminderTime: args.reminderTime,
          ),
        );
      case baseUrlSettings:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BaseUrlScreen(),
        );
      default:
        return null;
    }
  }
}
