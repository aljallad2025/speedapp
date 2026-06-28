import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../fleet/fleet_screen.dart';
import '../fleet/car_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _carService = CarService();
  List<CarModel> _featuredCars = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
  }

  Future<void> _loadFeatured() async {
    try {
      final cars = await _carService.getCars();
      setState(() {
        _featuredCars = cars.take(6).toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  void _goToFleet({String filter = 'all'}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FleetScreen(initialFilter: filter)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('SPEED')),
      body: RefreshIndicator(
        onRefresh: _loadFeatured,
        color: AppColors.speedRed,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Hero banner
            GestureDetector(
              onTap: () => _goToFleet(),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.heroGradient,
                  ),
                  boxShadow: AppShadows.redGlow,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -30,
                      top: -30,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: -40,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إيجار وبيع السيارات',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'أفضل الأسعار في البحرين',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'تصفح الآن',
                                  style: TextStyle(
                                    color: AppColors.speedRedDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.arrow_back_ios_new,
                                    size: 12, color: AppColors.speedRedDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            // Quick categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CategoryItem(
                  icon: Icons.directions_car,
                  label: 'اقتصادية',
                  onTap: () => _goToFleet(filter: 'rent'),
                ),
                _CategoryItem(
                  icon: Icons.airport_shuttle,
                  label: 'SUV',
                  onTap: () => _goToFleet(filter: 'rent'),
                ),
                _CategoryItem(
                  icon: Icons.star_outline,
                  label: 'فاخرة',
                  onTap: () => _goToFleet(filter: 'rent'),
                ),
                _CategoryItem(
                  icon: Icons.sell_outlined,
                  label: 'للبيع',
                  onTap: () => _goToFleet(filter: 'sale'),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'سيارات مميزة',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
                GestureDetector(
                  onTap: () => _goToFleet(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'عرض الكل',
                        style: TextStyle(
                            color: AppColors.speedRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_back_ios_new,
                          size: 11, color: AppColors.speedRed),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.speedRed),
                    ),
                  )
                : _error != null
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.error.withOpacity(0.2)),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 11),
                        ),
                      )
                    : SizedBox(
                        height: 195,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _featuredCars.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final car = _featuredCars[index];
                            return _FeaturedCard(
                              car: car,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CarDetailScreen(carId: car.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.heroGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.speedRed.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 7),
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;

  const _FeaturedCard({required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: car.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: car.images.first,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.greyLight,
                            child: const Icon(Icons.directions_car,
                                color: AppColors.greyMedium),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: car.listingType == 'sale'
                          ? AppColors.saleBadge
                          : AppColors.rentBadge,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      car.listingType == 'sale' ? 'للبيع' : 'إيجار',
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.isForRent && car.dailyRate != null
                        ? 'BD ${car.dailyRate!.toStringAsFixed(0)} / يوم'
                        : car.salePrice != null
                            ? 'BD ${car.salePrice!.toStringAsFixed(0)}'
                            : '',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.speedRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}