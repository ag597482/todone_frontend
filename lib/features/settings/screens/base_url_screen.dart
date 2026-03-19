import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todone_frontend/core/constants/api_constants.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';
import 'package:todone_frontend/core/theme/theme_mode_notifier.dart';

enum BaseUrlOption { localhost, railway, custom }

class BaseUrlScreen extends StatefulWidget {
  const BaseUrlScreen({super.key});

  @override
  State<BaseUrlScreen> createState() => _BaseUrlScreenState();
}

class _BaseUrlScreenState extends State<BaseUrlScreen> {
  static const String _localhostUrl = 'http://localhost:8080';
  static const String _railwayUrl = 'https://todone-todone.up.railway.app';

  final BaseUrlService _baseUrlService = BaseUrlService();
  final UserStorageService _userStorage = UserStorageService();
  final UserService _userService = UserService();
  final TextEditingController _customController = TextEditingController();
  final TextEditingController _telegramTokenController =
      TextEditingController();

  BaseUrlOption _selectedOption = BaseUrlOption.railway;
  bool _loading = true;
  String? _userId;
  bool _telegramIntegrating = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
    _loadUserId();
  }

  @override
  void dispose() {
    _customController.dispose();
    _telegramTokenController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final user = await _userStorage.getUser();
    if (mounted) setState(() => _userId = user?.userId);
  }

  Future<void> _loadCurrentUrl() async {
    final current = await _baseUrlService.getBaseUrl();
    setState(() {
      if (current == _localhostUrl) {
        _selectedOption = BaseUrlOption.localhost;
      } else if (current == _railwayUrl) {
        _selectedOption = BaseUrlOption.railway;
      } else {
        _selectedOption = BaseUrlOption.custom;
        _customController.text = current;
      }
      _loading = false;
    });
  }

  String get _currentUrl {
    switch (_selectedOption) {
      case BaseUrlOption.localhost:
        return _localhostUrl;
      case BaseUrlOption.railway:
        return _railwayUrl;
      case BaseUrlOption.custom:
        return _customController.text.trim();
    }
  }

  Future<void> _integrateTelegram() async {
    final token = _telegramTokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.telegramPleaseEnterToken)),
      );
      return;
    }
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in again')));
      return;
    }
    setState(() => _telegramIntegrating = true);
    final result = await _userService.patchTelegram(userId, token);
    if (!mounted) return;
    setState(() => _telegramIntegrating = false);
    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.telegramLinkedSuccess)),
        );
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _save() async {
    final url = _currentUrl;
    if (url.isEmpty && _selectedOption == BaseUrlOption.custom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.baseUrlPleaseEnter)),
      );
      return;
    }
    final toSave = url.isEmpty ? ApiConstants.defaultBaseUrl : url;
    await _baseUrlService.setBaseUrl(toSave);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.baseUrlSaved)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = context.watch<ThemeModeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.baseUrlSettingsTitle),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.baseUrlSettingsSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<BaseUrlOption>(
                    value: _selectedOption,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: BaseUrlOption.localhost,
                        child: Text(
                          AppStrings.baseUrlOptionLocalhost,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: BaseUrlOption.railway,
                        child: Text(
                          AppStrings.baseUrlOptionRailway,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: BaseUrlOption.custom,
                        child: Text(AppStrings.baseUrlOptionCustom),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedOption = value);
                      }
                    },
                  ),
                  if (_selectedOption == BaseUrlOption.custom) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customController,
                      decoration: InputDecoration(
                        hintText: AppStrings.baseUrlHint,
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(AppStrings.save),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                          isSelected: themeNotifier.themeMode == ThemeMode.dark,
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
                          isSelected:
                              themeNotifier.themeMode == ThemeMode.system,
                          onTap: () =>
                              themeNotifier.setThemeMode(ThemeMode.system),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Telegram integration
                  Text(
                    AppStrings.telegramIntegration,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.telegramBotTokenHint,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _telegramTokenController,
                    decoration: InputDecoration(
                      hintText: AppStrings.telegramBotTokenHint,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    obscureText: false,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _telegramIntegrating
                          ? null
                          : _integrateTelegram,
                      icon: _telegramIntegrating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.link, size: 20),
                      label: Text(
                        _telegramIntegrating
                            ? 'Linking...'
                            : AppStrings.integrate,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
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
