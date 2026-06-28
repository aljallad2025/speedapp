import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/car_model.dart';

String areaLabel(String code) {
  const map = {
    'amwaj': 'أمواج',
    'manama': 'المنامة',
    'muharraq': 'المحرق',
    'riffa': 'الرفاع',
    'seef': 'السيف',
    'isa town': 'مدينة عيسى',
    'hamad town': 'مدينة حمد',
  };
  return map[code.toLowerCase()] ?? code;
}

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;

  const CarCard({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: car.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: car.images.first,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.greyLight,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.greyLight,
                              child: const Icon(Icons.directions_car,
                                  size: 40, color: AppColors.greyMedium),
                            ),
                          )
                        : Container(
                            color: AppColors.greyLight,
                            child: const Icon(Icons.directions_car,
                                size: 40, color: AppColors.greyMedium),
                          ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!car.isAvailable)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.45),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.speedBlack,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Text(
                            'غير متاح حالياً',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _Badge(
                      text: car.listingType == 'sale'
                          ? 'للبيع'
                          : car.listingType == 'both'
                              ? 'إيجار / بيع'
                              : 'إيجار',
                      color: car.listingType == 'sale'
                          ? AppColors.saleBadge
                          : AppColors.rentBadge,
                    ),
                  ),
                  if (car.location != null && car.location!.isNotEmpty)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 11, color: AppColors.white),
                            const SizedBox(width: 3),
                            Text(
                              areaLabel(car.location!),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (car.transmission != null ||
                        car.fuelType != null ||
                        car.seats != null) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (car.transmission != null)
                            _SpecChip(
                              icon: Icons.settings_outlined,
                              label: car.transmission!,
                            ),
                          if (car.fuelType != null)
                            _SpecChip(
                              icon: Icons.local_gas_station_outlined,
                              label: car.fuelType!,
                            ),
                          if (car.seats != null)
                            _SpecChip(
                              icon: Icons.event_seat_outlined,
                              label: '${car.seats} مقاعد',
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (car.isForRent && car.dailyRate != null)
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'BD ${car.dailyRate!.toStringAsFixed(0)} ',
                                  style: const TextStyle(
                                    color: AppColors.speedRed,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                const TextSpan(
                                  text: '/ يوم',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (car.isForSale && car.salePrice != null)
                          Text(
                            'BD ${car.salePrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          )
                        else
                          const SizedBox(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.bg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 13,
                            color: AppColors.speedBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.greyDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.greyDark),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}