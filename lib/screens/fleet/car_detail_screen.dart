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
          SliverToBoxAdapter(
            child: _CarImageHeader(
              images: car.images,
              isFavorite: _isFavorite,
              onBack: () => Navigator.of(context).pop(),
              onToggleFavorite: _toggleFavorite,
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            car.displayName,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (car.isForRent && car.dailyRate != null)
                          _PricePill(
                            text: 'BD ${car.dailyRate!.toStringAsFixed(0)}/يوم',
                            color: AppColors.speedRed,
                          )
                        else if (car.isForSale && car.salePrice != null)
                          _PricePill(
                            text: 'BD ${car.salePrice!.toStringAsFixed(0)}',
                            color: AppColors.speedBlack,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (car.category != null)
                          _Tag(icon: Icons.category_outlined, text: car.category!),
                        if (car.transmission != null)
                          _Tag(icon: Icons.settings_outlined, text: car.transmission!),
                        if (car.fuelType != null)
                          _Tag(icon: Icons.local_gas_station_outlined, text: car.fuelType!),
                        if (car.seats != null)
                          _Tag(icon: Icons.event_seat_outlined, text: '${car.seats} مقاعد'),
                      ],
                    ),
                    if (car.description != null) ...[
                      const SizedBox(height: 22),
                      const Text(
                        'نظرة عامة',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          car.description!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13.5, height: 1.6),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          'التقييمات',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        if (_reviews.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              '${(_reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length).toStringAsFixed(1)} ★',
                              style: const TextStyle(
                                  fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_reviews.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: const Text('لا توجد تقييمات بعد',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                      )
                    else
                      ..._reviews.map((r) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: AppColors.speedBlack,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.person, size: 17, color: AppColors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(5, (i) => Icon(
                                              i < r.rating.round() ? Icons.star : Icons.star_border,
                                              size: 14,
                                              color: AppColors.warning,
                                            )),
                                      ),
                                      if (r.comment != null) ...[
                                        const SizedBox(height: 5),
                                        Text(r.comment!,
                                            style: const TextStyle(
                                                fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.speedBlack.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
      return Row(
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

class _PricePill extends StatelessWidget {
  final String text;
  final Color color;
  const _PricePill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.greyDark),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

/// سلايدر صور احترافي بمؤشرات نقاط + أزرار رجوع/مفضلة عائمة
class _CarImageHeader extends StatefulWidget {
  final List<String> images;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;

  const _CarImageHeader({
    required this.images,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
  });

  @override
  State<_CarImageHeader> createState() => _CarImageHeaderState();
}

class _CarImageHeaderState extends State<_CarImageHeader> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final slideCount = images.isEmpty ? 1 : images.length;

    return Stack(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _controller,
            itemCount: slideCount,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              if (images.isEmpty) {
                return Container(
                  color: AppColors.speedBlackSoft,
                  child: const Center(
                    child: Icon(Icons.directions_car,
                        size: 64, color: Color(0xFF3A3A3A)),
                  ),
                );
              }
              return CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Container(
                  color: AppColors.speedBlackSoft,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.speedBlackSoft,
                  child: const Center(
                    child: Icon(Icons.directions_car,
                        size: 64, color: Color(0xFF3A3A3A)),
                  ),
                ),
              );
            },
          ),
        ),

        // تظليل خفيف فوق وتحت عشان الأزرار والنقاط تظهر بوضوح فوق أي صورة
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // زر الرجوع
        Positioned(
          top: 14,
          right: 14,
          child: _CircleIconButton(
            icon: Icons.arrow_forward,
            onTap: widget.onBack,
          ),
        ),

        // زر المفضلة
        Positioned(
          top: 14,
          left: 14,
          child: _CircleIconButton(
            icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            iconColor: widget.isFavorite ? AppColors.speedRed : AppColors.white,
            onTap: widget.onToggleFavorite,
          ),
        ),

        // نقاط المؤشر
        if (slideCount > 1)
          Positioned(
            bottom: 34,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slideCount, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.speedRed : AppColors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
    );
  }
}