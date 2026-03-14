import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
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
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                                '${AppStrings.goodMorning}, Aman',
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
                              '4 ${AppStrings.tasksLeft}',
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
                      // Task Cards
                      TaskCard(
                        title: AppStrings.finalizeProjectProposal,
                        description: AppStrings.projectProposalDesc,
                        label: AppStrings.dueToday,
                        labelColor: const Color(0xFF4F46E5),
                        labelBgColor:
                            const Color(0xFF4F46E5).withOpacity(0.1),
                        time: '09:00 AM',
                        hasAISteps: true,
                        hasNotes: true,
                      ),
                      const SizedBox(height: 16),
                      TaskCard(
                        title: AppStrings.weeklySyncMeeting,
                        description: AppStrings.weeklySyncDesc,
                        label: AppStrings.rolledOver,
                        labelColor: const Color(0xFFA16207),
                        labelBgColor: const Color(0xFFFEF3C7),
                        time: '11:30 AM',
                        hasAISteps: true,
                        hasNotes: false,
                      ),
                      const SizedBox(height: 16),
                      TaskCard(
                        title: AppStrings.designSystemUpdate,
                        description: AppStrings.designSystemDesc,
                        label: AppStrings.dueToday,
                        labelColor: const Color(0xFF4F46E5),
                        labelBgColor:
                            const Color(0xFF4F46E5).withOpacity(0.1),
                        time: '02:00 PM',
                        hasAISteps: false,
                        hasNotes: true,
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
            Navigator.pushNamed(context, AppRoutes.createTask);
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
