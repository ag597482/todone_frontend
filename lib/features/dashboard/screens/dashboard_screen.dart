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
  final TaskGroupService _taskGroupService = TaskGroupService();
  final UserStorageService _userStorage = UserStorageService();
  final NotificationService _notificationService = NotificationService();

  late DateTime _selectedDate;
  List<TaskModel> _tasks = [];

  /// task_group_id -> display name (from GET /api/task-groups).
  Map<String, String> _taskGroupNames = {};
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
        _taskGroupNames = {};
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
        // Hide completed tasks whose dueDate is before/after the selected day.
        final selectedDateStr =
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
        final filtered = list.where((t) {
          if (t.status == 'COMPLETED' &&
              t.dueDate != null &&
              t.dueDate!.isNotEmpty &&
              t.dueDate != selectedDateStr) {
            return false;
          }
          return true;
        }).toList();

        // Sort tasks by time within the selected date (earliest first).
        final sorted = List<TaskModel>.from(filtered);
        sorted.sort((a, b) {
          final at = a.sortDateTime;
          final bt = b.sortDateTime;
          if (at == null && bt == null) return 0;
          if (at == null) return 1; // put tasks without time at the end
          if (bt == null) return -1;
          return at.compareTo(bt);
        });

        final groupsResult = await _taskGroupService.getTaskGroups(user.userId);
        if (!mounted) return;
        final nameMap = <String, String>{};
        switch (groupsResult) {
          case ApiSuccess(data: final groups):
            for (final g in groups) {
              nameMap[g.taskGroupId] = g.name.isNotEmpty
                  ? g.name
                  : g.taskGroupId;
            }
          case ApiFailure():
            break;
        }

        setState(() {
          _tasks = sorted;
          _taskGroupNames = nameMap;
          _loading = false;
          _error = null;
        });
      case ApiFailure(message: final message):
        setState(() {
          _tasks = [];
          _taskGroupNames = {};
          _loading = false;
          _error = message;
        });
    }
  }

  Widget _taskCardWidget(TaskModel task) {
    return TaskCard(
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
      subtaskCompleted: task.steps.where((s) => s.completed).length,
      subtaskTotal: task.steps.isEmpty ? null : task.steps.length,
    );
  }

  List<Widget> _buildGroupedTaskSections(BuildContext context) {
    final displayed = _displayedTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ungrouped = displayed
        .where((t) => t.taskGroupId == null || t.taskGroupId!.isEmpty)
        .toList();

    final grouped = <String, List<TaskModel>>{};
    for (final t in displayed) {
      final gid = t.taskGroupId;
      if (gid == null || gid.isEmpty) continue;
      grouped.putIfAbsent(gid, () => []).add(t);
    }

    final sortedGroupIds = grouped.keys.toList()
      ..sort(
        (a, b) => (_taskGroupNames[a] ?? a).toLowerCase().compareTo(
          (_taskGroupNames[b] ?? b).toLowerCase(),
        ),
      );

    final out = <Widget>[];

    for (final t in ungrouped) {
      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _taskCardWidget(t),
        ),
      );
    }

    for (final gid in sortedGroupIds) {
      final title = _taskGroupNames[gid] ?? AppStrings.unknownTaskGroup;
      final tasks = grouped[gid]!;
      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _TaskGroupGlanceCard(
            isDark: isDark,
            groupTitle: title,
            tasks: tasks,
            taskCards: [
              for (final t in tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _taskCardWidget(t),
                ),
            ],
          ),
        ),
      );
    }

    return out;
  }

  String _formatDate(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
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
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(fontSize: 24),
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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
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
                          ..._buildGroupedTaskSections(context),
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

/// Group card with horizontal “glance” chips so task names are visible while collapsed.
class _TaskGroupGlanceCard extends StatelessWidget {
  const _TaskGroupGlanceCard({
    required this.isDark,
    required this.groupTitle,
    required this.tasks,
    required this.taskCards,
  });

  final bool isDark;
  final String groupTitle;
  final List<TaskModel> tasks;
  final List<Widget> taskCards;

  static const _brand = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(color: _brand.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: _brand.withValues(alpha: isDark ? 0.14 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Material(
            color: Colors.transparent,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(12, 12, 8, 4),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              childrenPadding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              shape: const Border(),
              collapsedShape: const Border(),
              leading: const _GlanceLeadingIcon(),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      groupTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: -0.3,
                        height: 1.2,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TaskCountGlancePill(count: tasks.length, isDark: isDark),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.taskGroupGlanceLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 72,
                      child: Builder(
                        builder: (context) {
                          const maxChips = 4;
                          final displayed = tasks.length > maxChips
                              ? tasks.take(maxChips).toList()
                              : tasks;
                          final remaining = tasks.length - displayed.length;

                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            itemCount:
                                displayed.length + (remaining > 0 ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              if (i < displayed.length) {
                                final t = displayed[i];
                                return _GlanceTaskNameChip(
                                  title: t.title,
                                  isDone: t.status == 'COMPLETED',
                                  isDark: isDark,
                                );
                              }
                              return _GlanceTaskNameChip(
                                title: '+$remaining more',
                                isDone: false,
                                isDark: isDark,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              initiallyExpanded: false,
              children: taskCards,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlanceLeadingIcon extends StatelessWidget {
  const _GlanceLeadingIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.layers_rounded, color: Colors.white, size: 24),
    );
  }
}

class _TaskCountGlancePill extends StatelessWidget {
  const _TaskCountGlancePill({required this.count, required this.isDark});

  final int count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF4F46E5),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE0E7FF) : const Color(0xFF4338CA),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlanceTaskNameChip extends StatelessWidget {
  const _GlanceTaskNameChip({
    required this.title,
    required this.isDone,
    required this.isDark,
  });

  final String title;
  final bool isDone;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fill = isDark ? const Color(0xFF334155) : const Color(0xFFEEF2FF);
    final border = const Color(
      0xFF4F46E5,
    ).withValues(alpha: isDark ? 0.4 : 0.22);

    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border, width: 1),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        title.isEmpty ? '—' : title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          height: 1.2,
          decoration: isDone ? TextDecoration.lineThrough : null,
          decorationColor: isDark ? Colors.white54 : Colors.black38,
          decorationThickness: 1.5,
          color: isDone
              ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
              : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF312E81)),
        ),
      ),
    );
  }
}
