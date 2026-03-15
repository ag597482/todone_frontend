import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';
import 'package:todone_frontend/routes/index.dart';
import 'package:todone_frontend/core/theme/theme_mode_notifier.dart';
import 'package:todone_frontend/features/profile/widgets/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserStorageService _userStorage = UserStorageService();
  final UserService _userService = UserService();

  UserProfileData? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  static String _formatTaskDate(String? dueDate) {
    if (dueDate == null || dueDate.isEmpty) return '--';
    try {
      final d = DateTime.parse(dueDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final taskDay = DateTime(d.year, d.month, d.day);
      if (taskDay == today) return 'Today';
      if (taskDay == yesterday) return 'Yesterday';
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return dueDate;
    }
  }

  Future<void> _loadProfile() async {
    final user = await _userStorage.getUser();
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Please log in again';
      });
      return;
    }
    final result = await _userService.getProfile(user.userId);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: final data):
        setState(() {
          _profile = data;
          _loading = false;
          _error = null;
        });
      case ApiFailure(message: final message):
        setState(() {
          _profile = null;
          _loading = false;
          _error = message;
        });
    }
  }

  Future<void> _showEditNameDialog() async {
    final nameController = TextEditingController(
      text: _profile?.user.name ?? '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();
    if (result != true || _profile == null) return;
    final newName = nameController.text.trim();
    if (newName.isEmpty) return;

    final userId = _profile!.user.userId;
    final updateResult = await _userService.updateUserName(userId, newName);
    if (!mounted) return;
    switch (updateResult) {
      case ApiSuccess():
        await _userStorage.updateStoredUserName(newName);
        setState(() {
          _profile = UserProfileData(
            user: ProfileUser(
              userId: _profile!.user.userId,
              name: newName,
              phoneNumber: _profile!.user.phoneNumber,
              metadata: _profile!.user.metadata,
            ),
            completedTasksCount: _profile!.completedTasksCount,
            pendingTasksCount: _profile!.pendingTasksCount,
            tasks: _profile!.tasks,
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name updated')),
          );
        }
      case ApiFailure(message: final message):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = context.watch<ThemeModeNotifier>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.baseUrlSettings);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadProfile,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeaderWidget(
                        name: _profile?.user.name.isEmpty == false
                            ? _profile!.user.name
                            : 'User',
                        subtitle: _profile?.user.phoneNumber ?? '',
                        onEditProfile: _showEditNameDialog,
                      ),
                      const SizedBox(height: 24),

                      // Task counts from API
                      Text(
                        AppStrings.productivityAnalytics,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              label: AppStrings.completed,
                              value: '${_profile?.completedTasksCount ?? 0}',
                              icon: Icons.task_alt,
                              iconColor: const Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              label: 'Pending',
                              value: '${_profile?.pendingTasksCount ?? 0}',
                              icon: Icons.schedule,
                              iconColor: const Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Task list from profile API
                      if (_profile?.tasks.isNotEmpty ?? false) ...[
                        Text(
                          AppStrings.recentHistory,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_profile!.tasks.length, (i) {
                          final task = _profile!.tasks[i];
                          final dateStr = _formatTaskDate(task.dueDate);
                          final status = task.status?.toUpperCase() == 'COMPLETED'
                              ? TaskStatus.done
                              : TaskStatus.pending;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i < _profile!.tasks.length - 1 ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.taskDetail,
                                  arguments: TaskDetailArgs(
                                    taskTitle: task.title,
                                    taskDescription: task.description,
                                    category: task.displayLabel,
                                    dueDate: task.dueDate ?? '',
                                    reminderTime: task.timeDisplay,
                                    taskId: task.id,
                                    userId: _profile!.user.userId,
                                  ),
                                ).then((_) => _loadProfile());
                              },
                              child: TaskHistoryItem(
                                title: task.title,
                                date: dateStr,
                                status: status,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // Appearance (Theme) Section
                      Text(
                        AppStrings.appearance,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _ThemeOptionTile(
                              label: AppStrings.themeLight,
                              icon: Icons.light_mode_outlined,
                              isSelected:
                                  themeNotifier.themeMode == ThemeMode.light,
                              onTap: () =>
                                  themeNotifier.setThemeMode(ThemeMode.light),
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                            _ThemeOptionTile(
                              label: AppStrings.themeDark,
                              icon: Icons.dark_mode_outlined,
                              isSelected:
                                  themeNotifier.themeMode == ThemeMode.dark,
                              onTap: () =>
                                  themeNotifier.setThemeMode(ThemeMode.dark),
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                            _ThemeOptionTile(
                              label: AppStrings.themeSystem,
                              icon: Icons.brightness_auto_outlined,
                              isSelected: themeNotifier.themeMode ==
                                  ThemeMode.system,
                              onTap: () =>
                                  themeNotifier.setThemeMode(ThemeMode.system),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _userStorage.clearUser();
                            if (!context.mounted) return;
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.auth,
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: Text(AppStrings.logout),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        size: 22,
        color: isSelected
            ? const Color(0xFF4F46E5)
            : (isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B)),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? const Color(0xFF4F46E5)
              : (isDark
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF334155)),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle,
              color: Color(0xFF4F46E5), size: 22)
          : null,
      onTap: onTap,
    );
  }
}
