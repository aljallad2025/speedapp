import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/car_model.dart';
import '../../services/auth_service.dart';
import '../../services/favorite_service.dart';
import '../../services/car_service.dart';
import '../../widgets/car_card.dart';
import '../fleet/car_detail_screen.dart';
import '../auth/login_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _authService = AuthService();
  final _favoriteService = FavoriteService();
  final _carService = CarService();

  List<CarModel> _cars = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final favIds = await _favoriteService.getFavoriteCarIds(userId);
      final allCars = await _carService.getCars();
      setState(() {
        _cars = allCars.where((c) => favIds.contains(c.id)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _cars = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authService.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('المفضلة')),
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
                  child: const Icon(Icons.favorite_outline,
                      size: 36, color: AppColors.speedRed),
                ),
                const SizedBox(height: 18),
                const Text('سجل دخول لعرض مفضلتك',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      if (result == true) _load();
                    },
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
      appBar: AppBar(title: const Text('المفضلة')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.speedRed))
          : _cars.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.greyLight,
                        ),
                        child: const Icon(Icons.favorite_outline,
                            size: 36, color: AppColors.greyMedium),
                      ),
                      const SizedBox(height: 16),
                      const Text('لا توجد سيارات مفضلة',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.speedRed,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cars.length,
                    itemBuilder: (context, index) {
                      final car = _cars[index];
                      return CarCard(
                        car: car,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CarDetailScreen(carId: car.id),
                            ),
                          ).then((_) => _load());
                        },
                      );
                    },
                  ),
                ),
    );
  }
}