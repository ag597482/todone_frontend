import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/api_constants.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';

enum BaseUrlOption {
  localhost,
  railway,
  custom,
}

class BaseUrlScreen extends StatefulWidget {
  const BaseUrlScreen({super.key});

  @override
  State<BaseUrlScreen> createState() => _BaseUrlScreenState();
}

class _BaseUrlScreenState extends State<BaseUrlScreen> {
  static const String _localhostUrl = 'http://localhost:8080';
  static const String _railwayUrl = 'https://todone-todone.up.railway.app';

  final BaseUrlService _baseUrlService = BaseUrlService();
  final TextEditingController _customController = TextEditingController();

  BaseUrlOption _selectedOption = BaseUrlOption.railway;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.baseUrlSaved)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                ],
              ),
            ),
    );
  }
}
