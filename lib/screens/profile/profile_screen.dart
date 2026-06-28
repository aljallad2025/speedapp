import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/app_user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  AppUserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_authService.isLoggedIn) {
      try {
        final user = await _authService.getCurrentUserProfile();
        setState(() {
          _user = user;
          _loading = false;
        });
      } catch (_) {
        setState(() => _loading = false);
      }
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    setState(() {
      _user = null;
    });
  }

  Future<void> _goToLogin() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.speedRed),
        ),
      );
    }

    if (!_authService.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline,
                  size: 60, color: AppColors.greyMedium),
              const SizedBox(height: 16),
              const Text('سجل دخول للاستفادة من كل الميزات'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goToLogin,
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.speedRed,
            child: Text(
              (_user?.fullName?.isNotEmpty == true
                      ? _user!.fullName![0]
                      : 'S')
                  .toUpperCase(),
              style: const TextStyle(
                  fontSize: 32,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _user?.fullName ?? '',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              _user?.email ?? '',
              style: const TextStyle(color: AppColors.greyDark),
            ),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
