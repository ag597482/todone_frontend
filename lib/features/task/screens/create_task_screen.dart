import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';
import '../widgets/index.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  int _previousTabIndex = 0;
  final _oneTimeFormKey = GlobalKey<OneTimeTaskFormState>();
  final _taskService = TaskService();
  final _taskGroupService = TaskGroupService();
  final _userStorage = UserStorageService();
  List<TaskGroupModel> _taskGroups = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTaskGroups();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final idx = _tabController.index;
    if (_previousTabIndex == 2 && idx == 0) {
      _loadTaskGroups();
    }
    _previousTabIndex = idx;
    setState(() {
      _currentTabIndex = idx;
    });
  }

  Future<void> _loadTaskGroups() async {
    final user = await _userStorage.getUser();
    if (user == null || !mounted) return;
    final result = await _taskGroupService.getTaskGroups(user.userId);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: final list):
        setState(() => _taskGroups = list);
      case ApiFailure():
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onSaveTapped() async {
    if (_currentTabIndex == 2) {
      return;
    }

    if (_currentTabIndex == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine saved!')),
      );
      return;
    }

    final user = await _userStorage.getUser();
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseLogInAgain)),
      );
      return;
    }

    final payload = _oneTimeFormKey.currentState?.getTaskPayload();
    if (payload == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter task name and due date'),
        ),
      );
      return;
    }

    final taskGroupId = payload['taskGroupId'] as String?;

    final result = await _taskService.createTask(
      user.userId,
      name: payload['name'] as String,
      description: payload['description'] as String,
      dueDate: payload['dueDate'] as String,
      time: payload['time'] as String?,
      meta: payload['meta'] as Map<String, dynamic>?,
      taskGroupId: taskGroupId,
    );

    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: _):
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created')),
        );
        Navigator.pop(context);
      case ApiFailure(:final message):
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
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF0F172A).withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
            ),
            child: Icon(
              Icons.arrow_back,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
        title: Text(
          AppStrings.createTask,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
              indicatorColor: const Color(0xFF4F46E5),
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Text(
                    AppStrings.oneTimeTask,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    AppStrings.repetitiveTask,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    AppStrings.taskGroupsTab,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OneTimeTaskForm(
            key: _oneTimeFormKey,
            taskGroups: _taskGroups,
            onGenerateAISteps: (taskName, taskDescription) async {
              final result = await _taskService.generateSteps(taskName, taskDescription);
              switch (result) {
                case ApiSuccess(data: final steps):
                  return steps;
                case ApiFailure():
                  return null;
              }
            },
          ),
          const RepetitiveTaskForm(),
          TaskGroupsManageTab(
            onGroupsChanged: _loadTaskGroups,
          ),
        ],
      ),
      bottomNavigationBar: _currentTabIndex == 2
          ? Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.taskGroupsTabFooter,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: BackdropFilter(
                filter: const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.multiply,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => _onSaveTapped(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentTabIndex == 0
                                  ? Icons.task_alt
                                  : Icons.done_all,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentTabIndex == 0
                                  ? AppStrings.saveTask
                                  : AppStrings.saveRoutine,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
