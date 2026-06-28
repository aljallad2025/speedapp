import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/app_user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../booking/my_bookings_screen.dart';
import 'favorites_screen.dart';

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
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.speedRed.withOpacity(0.08),
                  ),
                  child: const Icon(Icons.person_outline,
                      size: 38, color: AppColors.speedRed),
                ),
                const SizedBox(height: 20),
                const Text(
                  'سجل دخول للاستفادة من كل الميزات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToLogin,
                    child: const Text('تسجيل الدخول'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.darkGradient,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: AppColors.heroGradient),
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.speedBlackSoft,
                    child: Text(
                      (_user?.fullName?.isNotEmpty == true
                              ? _user!.fullName![0]
                              : 'S')
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 30,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _user?.fullName ?? '',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '',
                  style: const TextStyle(color: Color(0xFFB8B8B8), fontSize: 13),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.event_note_outlined,
                  label: 'حجوزاتي',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                  ),
                ),
                _MenuTile(
                  icon: Icons.favorite_outline,
                  label: 'المفضلة',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.logout,
                  label: 'تسجيل الخروج',
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  onTap: _logout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.speedBlack,
    this.textColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: iconColor, size: 19),
        ),
        title: Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
        trailing: const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.greyMedium),
      ),
    );
  }
}