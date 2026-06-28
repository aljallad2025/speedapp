import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/car_model.dart';
import '../../models/review_model.dart';
import '../../services/car_service.dart';
import '../../services/auth_service.dart';
import '../../services/favorite_service.dart';
import '../../services/review_service.dart';
import '../auth/login_screen.dart';
import '../booking/booking_screen.dart';

/// TODO: غيّر هذا الرقم لرقم المبيعات/الشورووم الحقيقي (بصيغة دولية بدون +)
const String kSalesWhatsappNumber = '973XXXXXXXX';
const String kSalesPhoneNumber = '+973XXXXXXXX';

class CarDetailScreen extends StatefulWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final CarService _carService = CarService();
  final AuthService _authService = AuthService();
  final FavoriteService _favoriteService = FavoriteService();
  final ReviewService _reviewService = ReviewService();

  CarModel? _car;
  bool _loading = true;
  bool _isFavorite = false;
  List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    CarModel? car;
    List<ReviewModel> reviews = [];
    bool isFav = false;

    try {
      car = await _carService.getCarById(widget.carId);
    } catch (_) {}

    try {
      reviews = await _reviewService.getReviewsForCar(widget.carId);
    } catch (_) {
      // جدول reviews غير موجود بعد - عادي، نكمل بدون تقييمات
    }

    final userId = _authService.currentUser?.id;
    if (userId != null) {
      try {
        isFav = await _favoriteService.isFavorite(userId, widget.carId);
      } catch (_) {
        // جدول favorites غير موجود بعد - عادي
      }
    }

    if (!mounted) return;
    setState(() {
      _car = car;
      _reviews = reviews;
      _isFavorite = isFav;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (result != true) return;
    }
    final uid = _authService.currentUser?.id;
    if (uid == null) return;
    try {
      await _favoriteService.toggleFavorite(uid, widget.carId);
      setState(() => _isFavorite = !_isFavorite);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المفضلة غير متاحة حالياً')),
      );
    }
  }

  Future<void> _callSales() async {
    final uri = Uri(scheme: 'tel', path: kSalesPhoneNumber);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsappSales() async {
    final car = _car;
    final msg = car == null
        ? 'مرحباً، أنا مهتم بسيارة معروضة للبيع.'
        : 'مرحباً، أنا مهتم بسيارة ${car.displayName} المعروضة للبيع.';
    final uri = Uri.parse(
      'https://wa.me/$kSalesWhatsappNumber?text=${Uri.encodeComponent(msg)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _bookNow(CarModel car) async {
    if (!_authService.isLoggedIn) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (result != true) return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookingScreen(car: car)),
    );
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

    final car = _car;
    if (car == null) {
      return const Scaffold(body: Center(child: Text('السيارة غير موجودة')));
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.speedBlack,
            expandedHeight: 260,
            pinned: true,
            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.speedRed : AppColors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: car.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: car.images.first,
                      fit: BoxFit.cover,
                    )
                  : Container(color: AppColors.speedBlackSoft),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (car.category != null) _Tag(car.category!),
                      if (car.transmission != null) _Tag(car.transmission!),
                      if (car.fuelType != null) _Tag(car.fuelType!),
                      if (car.seats != null) _Tag('${car.seats} مقاعد'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (car.description != null) Text(car.description!),
                  const SizedBox(height: 24),
                  const Text(
                    'التقييمات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_reviews.isEmpty)
                    const Text('لا توجد تقييمات بعد',
                        style: TextStyle(color: AppColors.greyMedium))
                  else
                    ..._reviews.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.star,
                                  size: 16, color: AppColors.warning),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('${r.rating} / 5',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    if (r.comment != null)
                                      Text(r.comment!,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.greyDark)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildActionArea(car),
        ),
      ),
    );
  }

  Widget _buildActionArea(CarModel car) {
    // سيارة للإيجار فقط -> Book Now
    if (car.listingType == 'rent') {
      return ElevatedButton(
        onPressed: () => _bookNow(car),
        child: Text(
          car.dailyRate != null
              ? 'احجز الآن • BD ${car.dailyRate!.toStringAsFixed(0)}/يوم'
              : 'احجز الآن',
        ),
      );
    }

    // سيارة للبيع فقط -> اتصال + واتساب (بدون فلسفة، بسيط)
    if (car.listingType == 'sale') {
      return Column(
        children: [
          if (car.salePrice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'BD ${car.salePrice!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.speedBlack,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callSales,
                  icon: const Icon(Icons.call),
                  label: const Text('اتصال'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _whatsappSales,
                  icon: const Icon(Icons.chat),
                  label: const Text('واتساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // 'both' -> الخيارين
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _callSales,
            icon: const Icon(Icons.call),
            label: const Text('اتصال للبيع'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _bookNow(car),
            child: const Text('احجز للإيجار'),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
