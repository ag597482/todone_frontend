import 'package:flutter/material.dart';
import 'package:todone_frontend/core/service/index.dart';
import 'package:todone_frontend/routes/index.dart';

/// Shows loading then redirects to dashboard if user is stored, otherwise to auth.
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  final UserStorageService _userStorage = UserStorageService();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndNavigate());
  }

  Future<void> _checkAndNavigate() async {
    if (_navigated || !mounted) return;
    final hasUser = await _userStorage.hasUser();
    if (!mounted || _navigated) return;
    _navigated = true;
    final route =
        hasUser ? AppRoutes.dashboard : AppRoutes.auth;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
