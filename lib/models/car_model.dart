/// Car model
///
/// ⚠️ ملاحظة مهمة: أسماء الحقول هنا افتراضية بناءً على المنطق العام.
/// لازم نتأكد منها على جدول `cars` الحقيقي بالـ ERP (نتيجة \d cars بالـ psql)
/// قبل التوصيل النهائي، عشان نطابق أسماء الأعمدة 100% (نفس مبدأ
/// account_code بالمصاريف بالـ ERP - دقة الأعمدة أساسية).
class CarModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? plateNumber;
  final List<String> images;

  /// 'rent' | 'sale' | 'both'
  final String listingType;

  final double? dailyRate;
  final double? salePrice;

  final bool isAvailable;
  final String? category; // Economy / SUV / Luxury ...
  final String? transmission;
  final String? fuelType;
  final int? seats;
  final String? description;

  CarModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.plateNumber,
    this.images = const [],
    this.listingType = 'rent',
    this.dailyRate,
    this.salePrice,
    this.isAvailable = true,
    this.category,
    this.transmission,
    this.fuelType,
    this.seats,
    this.description,
  });

  bool get isForRent => listingType == 'rent' || listingType == 'both';
  bool get isForSale => listingType == 'sale' || listingType == 'both';

  String get displayName => '$make $model $year';

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'].toString(),
      make: json['make'] ?? json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] is int
          ? json['year']
          : int.tryParse('${json['year']}') ?? 0,
      plateNumber: json['plate_number'],
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      listingType: json['listing_type'] ?? 'rent',
      dailyRate: (json['daily_rate'] ?? json['rental_price'])?.toDouble(),
      salePrice: (json['sale_price'])?.toDouble(),
      isAvailable: json['is_available'] ?? true,
      category: json['category'],
      transmission: json['transmission'],
      fuelType: json['fuel_type'],
      seats: json['seats'],
      description: json['description'],
    );
  }
}
