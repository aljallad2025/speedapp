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
      });
    } catch (e) {
      setState(() => _loading = false);
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
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('SPEED')),
      body: RefreshIndicator(
        onRefresh: _loadFeatured,
        color: AppColors.speedRed,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hero banner
            GestureDetector(
              onTap: () => _goToFleet(),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.speedRed,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إيجار وبيع السيارات',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'أفضل الأسعار في البحرين',
                      style: TextStyle(color: Color(0xFFFCEBEB), fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'تصفح الآن',
                        style: TextStyle(
                          color: AppColors.speedRedDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

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

            const SizedBox(height: 26),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'سيارات مميزة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _goToFleet(),
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(color: AppColors.speedRed, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.speedRed),
                    ),
                  )
                : SizedBox(
                    height: 165,
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
                                builder: (_) =>
                                    CarDetailScreen(carId: car.id),
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
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.greyLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.greyDark, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
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
        width: 130,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 90,
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    car.isForRent && car.dailyRate != null
                        ? 'BD ${car.dailyRate!.toStringAsFixed(0)}/يوم'
                        : car.salePrice != null
                            ? 'BD ${car.salePrice!.toStringAsFixed(0)}'
                            : '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
