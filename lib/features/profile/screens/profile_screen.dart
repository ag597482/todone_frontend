import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';
import 'package:todone_frontend/routes/index.dart';
import 'package:todone_frontend/core/theme/theme_mode_notifier.dart';
import 'package:todone_frontend/features/profile/widgets/index.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            ProfileHeaderWidget(
              name: 'Jordan Sterling',
              title: 'Senior Flow Architect',
              avatarUrl: '',
              onEditProfile: () {
                // TODO: Navigate to edit profile
              },
            ),
            const SizedBox(height: 24),

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
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ThemeOptionTile(
                    label: AppStrings.themeLight,
                    icon: Icons.light_mode_outlined,
                    isSelected: themeNotifier.themeMode == ThemeMode.light,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  _ThemeOptionTile(
                    label: AppStrings.themeDark,
                    icon: Icons.dark_mode_outlined,
                    isSelected: themeNotifier.themeMode == ThemeMode.dark,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  _ThemeOptionTile(
                    label: AppStrings.themeSystem,
                    icon: Icons.brightness_auto_outlined,
                    isSelected: themeNotifier.themeMode == ThemeMode.system,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Productivity Analytics Title
            Text(
              AppStrings.productivityAnalytics,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricCard(
                  label: AppStrings.completed,
                  value: '142',
                  icon: Icons.task_alt,
                  iconColor: const Color(0xFF16A34A),
                  subtitle: '+14% vs last week',
                ),
                MetricCard(
                  label: AppStrings.missedTasks,
                  value: '12',
                  icon: Icons.close_rounded,
                  iconColor: const Color(0xFFDC2626),
                  subtitle: '-8% vs last week',
                ),
                MetricCard(
                  label: AppStrings.aiAssists,
                  value: '856',
                  icon: Icons.auto_awesome,
                  iconColor: const Color(0xFFA855F7),
                  subtitle: '+31% vs last week',
                ),
                MetricCard(
                  label: AppStrings.completionRate,
                  value: '92.4%',
                  icon: Icons.trending_up,
                  iconColor: const Color(0xFF4F46E5),
                  progressValue: 0.924,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Productivity Analysis Chart
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.productivityAnalysis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.thisWeek,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SevenDayChart(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent History Section (from API: GET /api/tasks/user/{userId} without date)
            const RecentHistorySection(),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await UserStorageService().clearUser();
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
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? const Color(0xFF4F46E5)
              : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF4F46E5), size: 22)
          : null,
      onTap: onTap,
    );
  }
}
