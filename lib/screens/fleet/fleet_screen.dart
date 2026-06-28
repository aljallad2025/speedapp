import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../widgets/car_card.dart';
import 'car_detail_screen.dart';

class FleetScreen extends StatefulWidget {
  /// 'all' | 'rent' | 'sale' - تقدر توصلها من Home لفتح فلتر معين مباشرة
  final String initialFilter;
  const FleetScreen({super.key, this.initialFilter = 'all'});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  final CarService _carService = CarService();
  List<CarModel> _cars = [];
  bool _loading = true;
  String? _error;

  late String _filter;

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

  List<CarModel> get _filteredCars {
    if (_filter == 'all') return _cars;
    if (_filter == 'rent') return _cars.where((c) => c.isForRent).toList();
    return _cars.where((c) => c.isForSale).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('SPEED'),
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
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_filteredCars.length} سيارة متاحة',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
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
                                Text('لا توجد سيارات حالياً',
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