import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import '../fleet/fleet_screen.dart';
import '../profile/favorites_screen.dart';
import '../booking/my_bookings_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    FleetScreen(),
    FavoritesScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  final _items = const [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'الرئيسية'),
    _NavItemData(icon: Icons.directions_car_outlined, activeIcon: Icons.directions_car, label: 'السيارات'),
    _NavItemData(icon: Icons.favorite_outline, activeIcon: Icons.favorite, label: 'المفضلة'),
    _NavItemData(icon: Icons.event_note_outlined, activeIcon: Icons.event_note, label: 'حجوزاتي'),
    _NavItemData(icon: Icons.person_outline, activeIcon: Icons.person, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.speedBlack.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == _index;
              final item = _items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _index = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.speedRed.withOpacity(0.10) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? AppColors.speedRed : AppColors.greyMedium,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? AppColors.speedRed : AppColors.greyMedium,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData({required this.icon, required this.activeIcon, required this.label});
}