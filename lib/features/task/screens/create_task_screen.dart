import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OneTimeTaskForm(),
          RepetitiveTaskForm(),
        ],
      ),
      bottomNavigationBar: Container(
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _currentTabIndex == 0
                            ? 'Task saved!'
                            : 'Routine saved!',
                      ),
                    ),
                  );
                },
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
