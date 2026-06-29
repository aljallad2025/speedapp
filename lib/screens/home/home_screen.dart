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
  List<CarModel> _saleCars = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await _carService.getCars();
      setState(() {
        _featuredCars = all.where((c) => c.isForRent).take(10).toList();
        _saleCars = all.where((c) => c.isForSale).take(10).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _goToFleet({String? filter}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FleetScreen(initialFilter: filter),
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: AppColors.speedRed,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.speedRed,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('SPEED', style: TextStyle(
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w900, letterSpacing: 2,
                  )),
                ],
              ),
              actions: [
                IconButton(icon: const Icon(Icons.search, color: Colors.white, size: 26), onPressed: () => _goToFleet()),
                IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26), onPressed: () {}),
                const SizedBox(width: 4),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSlider(),
                    const SizedBox(height: 24),
                    _buildCategories(),
                    const SizedBox(height: 28),
                    _buildSection('Featured Rentals', _featuredCars, 'rent'),
                    const SizedBox(height: 28),
                    _buildSection('Cars For Sale', _saleCars, 'sale'),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSlider() {
    if (_loading) {
      return Container(
        height: 190,
        decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(16)),
      );
    }
    final sliderCars = _featuredCars.take(5).toList();
    if (sliderCars.isEmpty) {
      return Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [AppColors.speedRedDark, AppColors.speedRed]),
        ),
        padding: const EdgeInsets.all(22),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rent Premium Cars', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('Best prices in Bahrain', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      );
    }
    return SizedBox(height: 190, child: PageView(
      
      children: sliderCars.map((car) {
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CarDetailScreen(carId: car.id))),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: car.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: car.images.first,
                        width: double.infinity, height: 190,
                        fit: BoxFit.cover,
                        
                      )
                    : Container(
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(colors: [AppColors.speedRedDark, AppColors.speedRed]),
                        ),
                      ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(car.isForSale ? 'For Sale' : 'For Rent',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 10),
                    Text(car.displayName,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(
                      car.isForRent && car.dailyRate != null
                          ? 'BD ${car.dailyRate!.toStringAsFixed(0)} / day'
                          : car.salePrice != null ? 'BD ${car.salePrice!.toStringAsFixed(0)}' : '',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text('View Details',
                          style: TextStyle(color: AppColors.speedRedDark, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList()),
  }

  Widget _buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CategoryItem(icon: Icons.directions_car, label: 'Economy', onTap: () => _goToFleet(filter: 'rent')),
        _CategoryItem(icon: Icons.airport_shuttle, label: 'SUV', onTap: () => _goToFleet(filter: 'rent')),
        _CategoryItem(icon: Icons.star_outline, label: 'Luxury', onTap: () => _goToFleet(filter: 'rent')),
        _CategoryItem(icon: Icons.sell_outlined, label: 'For Sale', onTap: () => _goToFleet(filter: 'sale')),
      ],
    );
  }

  Widget _buildSection(String title, List<CarModel> cars, String filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            GestureDetector(
              onTap: () => _goToFleet(filter: filter),
              child: Row(children: [
                Text('See All', style: TextStyle(color: AppColors.speedRed, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 3),
                Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.speedRed),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: AppColors.speedRed))
        else if (_error != null)
          Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 11))
        else if (cars.isEmpty)
          const Text('No cars available', style: TextStyle(color: AppColors.textSecondary))
        else
          SizedBox(
            height: 195,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final car = cars[index];
                return _FeaturedCard(
                  car: car,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CarDetailScreen(carId: car.id)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CategoryItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.heroGradient,
              ),
              boxShadow: [BoxShadow(color: AppColors.speedRed.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 7),
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                  child: SizedBox(
                    height: 100, width: double.infinity,
                    child: car.images.isNotEmpty
                        ? CachedNetworkImage(imageUrl: car.images.first, fit: BoxFit.cover)
                        : Container(color: AppColors.greyLight, child: const Icon(Icons.directions_car, color: AppColors.greyMedium)),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: car.isForSale ? AppColors.saleBadge : AppColors.rentBadge,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(car.isForSale ? 'Sale' : 'Rent',
                        style: const TextStyle(color: AppColors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    car.isForRent && car.dailyRate != null
                        ? 'BD ${car.dailyRate!.toStringAsFixed(0)} / day'
                        : car.salePrice != null ? 'BD ${car.salePrice!.toStringAsFixed(0)}' : '',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.speedRed),
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