import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';
import 'package:todone_frontend/routes/index.dart';
import '../widgets/index.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  final TaskService _taskService = TaskService();
  final UserStorageService _userStorage = UserStorageService();
  final NotificationService _notificationService = NotificationService();

  late DateTime _selectedDate;
  List<TaskModel> _tasks = [];
  bool _loading = true;
  String? _error;
  String _userName = '';
  String? _userId;
  bool _showOnlyPending = false;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadUserAndTasks();
  }

  Future<void> _loadUnreadNotificationCount() async {
    final user = await _userStorage.getUser();
    if (user == null) return;
    final result = await _notificationService.getNotifications(user.userId);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: final list):
        setState(() {
          _unreadNotificationCount = list
              .where((n) => n.status.toUpperCase() == 'DELIVERED')
              .length;
        });
      case ApiFailure():
        setState(() => _unreadNotificationCount = 0);
    }
  }

  List<TaskModel> get _displayedTasks => _showOnlyPending
      ? _tasks.where((t) => t.status != 'COMPLETED').toList()
      : _tasks;

  Future<void> _loadUserAndTasks() async {
    final user = await _userStorage.getUser();
    setState(() {
      _userName = user?.name.isNotEmpty == true ? user!.name : 'User';
      _userId = user?.userId;
    });
    await _fetchTasks();
    _loadUnreadNotificationCount();
  }

  Future<void> _fetchTasks() async {
    final user = await _userStorage.getUser();
    if (user == null) {
      setState(() {
        _tasks = [];
        _loading = false;
        _error = 'Please log in again';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _taskService.getTasksForUser(
      user.userId,
      date: _selectedDate,
    );

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

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _fetchTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Top Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _formatDate(_selectedDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppStrings.greetingString}, $_userName',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      fontSize: 24,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tasks Section
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchTasks,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.todaysTasks,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Text(
                              '${_tasks.where((t) => t.status != "COMPLETED").length} ${AppStrings.tasksLeft}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Show pending only',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: _showOnlyPending,
                            onChanged: (value) {
                              setState(() => _showOnlyPending = value);
                            },
                            activeTrackColor: const Color(0xFF4F46E5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Task list from API
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else if (_displayedTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              _showOnlyPending
                                  ? 'No pending tasks'
                                  : 'No tasks for this date',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate(
                          _displayedTasks.length,
                          (index) {
                            final task = _displayedTasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TaskCard(
                                title: task.title,
                                description: task.description,
                                label: task.displayLabel,
                                labelColor: task.labelColor,
                                labelBgColor: task.labelBgColor,
                                time: task.timeDisplay,
                                hasAISteps: task.hasAISteps,
                                hasNotes: task.hasNotes,
                                dueDate: task.dueDate,
                                taskId: task.id,
                                userId: _userId,
                                initialChecked: task.status == 'COMPLETED',
                                onStatusChanged: _fetchTasks,
                                onReturnFromDetail: () {
                                  if (mounted) _fetchTasks();
                                },
                                subtaskCompleted: task.steps
                                    .where((s) => s.completed)
                                    .length,
                                subtaskTotal: task.steps.isEmpty
                                    ? null
                                    : task.steps.length,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
        unreadNotificationCount: _unreadNotificationCount,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          // Navigate to Create Task on Create button tap
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.createTask).then((_) {
              if (mounted) _fetchTasks();
            });
            setState(() {
              _currentNavIndex = 0;
            });
          }
          // Navigate to Notification Screen on Alerts button tap
          if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.notification).then((_) {
              if (mounted) _loadUnreadNotificationCount();
            });
            setState(() {
              _currentNavIndex = 0;
            });
          }
          // Navigate to Profile Screen on Profile button tap
          if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.profile);
            setState(() {
              _currentNavIndex = 0;
            });
          }
        },
      ),
    );
  }
}
