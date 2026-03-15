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
  final TextEditingController _searchController = TextEditingController();
  final TaskService _taskService = TaskService();
  final UserStorageService _userStorage = UserStorageService();

  late DateTime _selectedDate;
  List<TaskModel> _tasks = [];
  bool _loading = true;
  String? _error;
  String _userName = '';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadUserAndTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndTasks() async {
    final user = await _userStorage.getUser();
    setState(() {
      _userName = user?.name.isNotEmpty == true ? user!.name : 'User';
      _userId = user?.userId;
    });
    await _fetchTasks();
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
                                '${AppStrings.goodMorning}, $_userName',
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
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchTasks,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tasks Section
              Expanded(
                child: SingleChildScrollView(
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
                              '${_tasks.length} ${AppStrings.tasksLeft}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
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
                      else if (_tasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'No tasks for this date',
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
                          _tasks.length,
                          (index) {
                            final task = _tasks[index];
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
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
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
            Navigator.pushNamed(context, AppRoutes.notification);
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
