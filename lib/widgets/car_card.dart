import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/car_model.dart';

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;

  const CarCard({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.speedBlack,
                    ),
                  ),
                  if (car.transmission != null ||
                      car.fuelType != null ||
                      car.seats != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (car.transmission != null)
                          _SpecChip(
                            icon: Icons.settings,
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
                            label: '${car.seats}',
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (car.isForRent && car.dailyRate != null)
                    Text(
                      'BD ${car.dailyRate!.toStringAsFixed(0)} / يوم',
                      style: const TextStyle(
                        color: AppColors.speedRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  if (car.isForSale && car.salePrice != null)
                    Text(
                      'BD ${car.salePrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.speedBlack,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.greyMedium),
          const SizedBox(width: 3),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
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
