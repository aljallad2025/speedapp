import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../services/booking_service.dart';
import '../../widgets/car_card.dart';
import 'car_detail_screen.dart';
import 'filter_sheet.dart';

class FleetScreen extends StatefulWidget {
  /// 'all' | 'rent' | 'sale' - تقدر توصلها من Home لفتح فلتر معين مباشرة
  final String initialFilter;
  const FleetScreen({super.key, this.initialFilter = 'all'});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  final CarService _carService = CarService();
  final BookingService _bookingService = BookingService();

  List<CarModel> _cars = [];
  bool _loading = true;
  String? _error;

  late String _filter;
  CarFilters _filters = const CarFilters();
  Set<String> _bookedCarIds = {};
  bool _checkingAvailability = false;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cars = await _carService.getCars();
      setState(() {
        _cars = cars;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل السيارات:\n$e';
        _loading = false;
      });
    }
  }

  List<String> get _availableLocations {
    final set = <String>{};
    for (final c in _cars) {
      if (c.location != null && c.location!.trim().isNotEmpty) {
        set.add(c.location!);
      }
    }
    return set.toList()..sort();
  }

  (double, double) get _priceBounds {
    final values = <double>[];
    for (final c in _cars) {
      if (c.dailyRate != null) values.add(c.dailyRate!);
      if (c.salePrice != null) values.add(c.salePrice!);
    }
    if (values.isEmpty) return (0, 100);
    var min = values.reduce((a, b) => a < b ? a : b);
    var max = values.reduce((a, b) => a > b ? a : b);
    if (min == max) max = min + 50;
    return (min.floorToDouble(), max.ceilToDouble());
  }

  Future<void> _openFilters() async {
    final bounds = _priceBounds;
    final result = await showCarFiltersSheet(
      context: context,
      locations: _availableLocations,
      priceBoundsMin: bounds.$1,
      priceBoundsMax: bounds.$2,
      initial: _filters,
    );
    if (result == null) return;
    setState(() => _filters = result);
    if (result.dateRange != null) {
      await _refreshAvailability(result.dateRange!);
    } else {
      setState(() => _bookedCarIds = {});
    }
  }

  Future<void> _refreshAvailability(DateTimeRange range) async {
    setState(() => _checkingAvailability = true);
    try {
      final ids = await _bookingService.getBookedCarIds(
        start: range.start,
        end: range.end,
      );
      setState(() {
        _bookedCarIds = ids.toSet();
        _checkingAvailability = false;
      });
    } catch (_) {
      setState(() => _checkingAvailability = false);
    }
  }

  void _clearAdvancedFilters() {
    setState(() {
      _filters = const CarFilters();
      _bookedCarIds = {};
    });
  }

  List<CarModel> get _filteredCars {
    var list = _cars;
    if (_filter == 'rent') {
      list = list.where((c) => c.isForRent).toList();
    } else if (_filter == 'sale') {
      list = list.where((c) => c.isForSale).toList();
    }

    if (_filters.location != null) {
      list = list.where((c) => c.location == _filters.location).toList();
    }
    if (_filters.priceRange != null) {
      final r = _filters.priceRange!;
      list = list.where((c) {
        final price = c.dailyRate ?? c.salePrice;
        if (price == null) return true;
        return price >= r.start && price <= r.end;
      }).toList();
    }
    if (_filters.dateRange != null) {
      list = list.where((c) => !_bookedCarIds.contains(c.id)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('SPEED'),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune),
                if (_filters.activeCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.speedRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: 'للإيجار',
                  selected: _filter == 'rent',
                  onTap: () => setState(() => _filter = 'rent'),
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: 'للبيع',
                  selected: _filter == 'sale',
                  onTap: () => setState(() => _filter = 'sale'),
                ),
              ],
            ),
          ),
          if (_filters.activeCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _clearAdvancedFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.speedRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${_filters.activeCount} فلاتر مفعّلة',
                            style: const TextStyle(
                                color: AppColors.speedRed, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.close, size: 14, color: AppColors.speedRed),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: _checkingAvailability
                    ? const Text('جاري فحص التوفر...',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5))
                    : Text(
                        '${_filteredCars.length} سيارة متاحة',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.speedRed),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off_rounded,
                                  size: 40, color: AppColors.greyMedium),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 12.5)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadCars,
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredCars.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.directions_car_outlined,
                                    size: 44, color: AppColors.greyMedium),
                                SizedBox(height: 10),
                                Text('لا توجد سيارات تطابق الفلاتر',
                                    style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCars,
                            color: AppColors.speedRed,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _filteredCars.length,
                              itemBuilder: (context, index) {
                                final car = _filteredCars[index];
                                return CarCard(
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
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.speedRed : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.speedRed : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.speedRed.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}