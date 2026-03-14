import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
import '../widgets/index.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
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
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
        title: Text(
          AppStrings.reminders,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.more_vert,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4F46E5),
            unselectedLabelColor: isDark
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFF4F46E5),
            indicatorWeight: 3,
            tabs: [
              Tab(text: AppStrings.all),
              Tab(text: AppStrings.unread),
              Tab(text: AppStrings.archived),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(context, isDark, 'all'),
          _buildNotificationsList(context, isDark, 'unread'),
          _buildNotificationsList(context, isDark, 'archived'),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    bool isDark,
    String filterType,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today Section
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              AppStrings.today,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
          ),
          NotificationCard(
            title: 'Submit Project Proposal',
            taskType: 'One-time Task',
            time: '10:00 AM',
            status: NotificationStatus.dueSoon,
            icon: Icons.schedule,
            iconColor: const Color(0xFFA16207),
            iconBgColor: const Color(0xFFFEF3C7),
          ),
          const SizedBox(height: 16),
          // Yesterday Section
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Text(
              AppStrings.yesterday,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
          ),
          NotificationCard(
            title: 'Morning Workout',
            taskType: 'Routine',
            time: '07:00 AM',
            status: NotificationStatus.missed,
            icon: Icons.notification_important,
            iconColor: const Color(0xFFBE123C),
            iconBgColor: const Color(0xFFFFE4E6),
          ),
          const SizedBox(height: 12),
          NotificationCard(
            title: 'Update Weekly Budget',
            taskType: 'Routine',
            time: '06:00 PM',
            status: NotificationStatus.rolledOver,
            icon: Icons.redo,
            iconColor: const Color(0xFF64748B),
            iconBgColor: const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 16),
          // Earlier Section
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Text(
              AppStrings.earlier,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
          ),
          NotificationCard(
            title: 'Email Marketing Team',
            taskType: 'One-time Task',
            time: 'Oct 24, 2:00 PM',
            status: NotificationStatus.new_,
            icon: Icons.mail,
            iconColor: const Color(0xFF4F46E5),
            iconBgColor: const Color(0xFFEEF2FF),
          ),
          const SizedBox(height: 16),
          // Swipe Hint
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark
                    ? const Color(0xFFBE123C).withOpacity(0.3)
                    : const Color(0xFFFFE4E6),
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isDark
                  ? const Color(0xFFBE123C).withOpacity(0.1)
                  : const Color(0xFFFEF3C7).withOpacity(0.3),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBE123C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppStrings.swipeToDismiss,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFBE123C)
                          : const Color(0xFFA16207),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_left,
                  color: isDark
                      ? const Color(0xFFBE123C).withOpacity(0.5)
                      : const Color(0xFFA16207).withOpacity(0.3),
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
