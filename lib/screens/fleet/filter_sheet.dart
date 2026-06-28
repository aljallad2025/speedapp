import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CarFilters {
  final String? location;
  final RangeValues? priceRange;
  final DateTimeRange? dateRange;

  const CarFilters({this.location, this.priceRange, this.dateRange});

  bool get isEmpty =>
      location == null && priceRange == null && dateRange == null;

  int get activeCount {
    var n = 0;
    if (location != null) n++;
    if (priceRange != null) n++;
    if (dateRange != null) n++;
    return n;
  }
}

Future<CarFilters?> showCarFiltersSheet({
  required BuildContext context,
  required List<String> locations,
  required double priceBoundsMin,
  required double priceBoundsMax,
  CarFilters initial = const CarFilters(),
}) {
  return showModalBottomSheet<CarFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(
      locations: locations,
      priceBoundsMin: priceBoundsMin,
      priceBoundsMax: priceBoundsMax,
      initial: initial,
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  final List<String> locations;
  final double priceBoundsMin;
  final double priceBoundsMax;
  final CarFilters initial;

  const _FilterSheet({
    required this.locations,
    required this.priceBoundsMin,
    required this.priceBoundsMax,
    required this.initial,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _location;
  late RangeValues _priceRange;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _location = widget.initial.location;
    _priceRange = widget.initial.priceRange ??
        RangeValues(widget.priceBoundsMin, widget.priceBoundsMax);
    _dateRange = widget.initial.dateRange;
  }

  String _areaLabel(String code) {
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

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.speedRed,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _reset() {
    setState(() {
      _location = null;
      _priceRange = RangeValues(widget.priceBoundsMin, widget.priceBoundsMax);
      _dateRange = null;
    });
  }

  void _apply() {
    final isFullRange = _priceRange.start <= widget.priceBoundsMin &&
        _priceRange.end >= widget.priceBoundsMax;
    Navigator.of(context).pop(
      CarFilters(
        location: _location,
        priceRange: isFullRange ? null : _priceRange,
        dateRange: _dateRange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الفلاتر',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  TextButton(onPressed: _reset, child: const Text('إعادة ضبط')),
                ],
              ),
              const SizedBox(height: 18),

              if (widget.locations.isNotEmpty) ...[
                const Text('المنطقة',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.locations.map((loc) {
                    final selected = _location == loc;
                    return GestureDetector(
                      onTap: () => setState(() => _location = selected ? null : loc),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.speedRed : AppColors.bg,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                              color: selected ? AppColors.speedRed : AppColors.border),
                        ),
                        child: Text(
                          _areaLabel(loc),
                          style: TextStyle(
                            color: selected ? AppColors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('نطاق السعر',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(
                    'BD ${_priceRange.start.round()} - ${_priceRange.end.round()}',
                    style: const TextStyle(color: AppColors.speedRed, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.speedRed,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.speedRed,
                  overlayColor: AppColors.speedRed.withOpacity(0.15),
                ),
                child: RangeSlider(
                  min: widget.priceBoundsMin,
                  max: widget.priceBoundsMax,
                  values: _priceRange,
                  onChanged: (v) => setState(() => _priceRange = v),
                ),
              ),
              const SizedBox(height: 10),

              const Text('تواريخ الإيجار',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDateRange,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.speedRed),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dateRange == null
                              ? 'اختر فترة الإيجار (تستثني السيارات المحجوزة)'
                              : '${_fmtDate(_dateRange!.start)} - ${_fmtDate(_dateRange!.end)}',
                          style: TextStyle(
                            color: _dateRange == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (_dateRange != null)
                        GestureDetector(
                          onTap: () => setState(() => _dateRange = null),
                          child: const Icon(Icons.close, size: 18, color: AppColors.greyMedium),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              ElevatedButton(
                onPressed: _apply,
                child: const Text('تطبيق الفلاتر'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}