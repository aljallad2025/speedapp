/// Car model - مبني على الـ schema الحقيقي بجدول `cars`
class CarModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? plateNumber;
  final List<String> images;

  /// مشتق من عمود `category` الحقيقي (قيمته 'rental' أو 'sale' حالياً)
  /// 'rent' | 'sale' | 'both'
  final String listingType;

  final double? dailyRate;
  final double? salePrice;

  final bool isAvailable;

  /// منطقة السيارة (عمود location الحقيقي - مثلاً 'amwaj')
  final String? location;

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
    this.location,
    this.transmission,
    this.fuelType,
    this.seats,
    this.description,
  });

  bool get isForRent => listingType == 'rent' || listingType == 'both';
  bool get isForSale => listingType == 'sale' || listingType == 'both';

  String get displayName => '$make $model $year';

  static String _deriveListingType(dynamic rawCategory) {
    final v = (rawCategory ?? '').toString().toLowerCase();
    if (v.contains('sale')) return 'sale';
    if (v.contains('both')) return 'both';
    return 'rent';
  }

  factory CarModel.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['image_url'];
    return CarModel(
      id: json['id'].toString(),
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] is int
          ? json['year']
          : int.tryParse('${json['year']}') ?? 0,
      plateNumber: json['plate_number'],
      images: (imageUrl != null && imageUrl.toString().isNotEmpty)
          ? [imageUrl.toString()]
          : const [],
      listingType: _deriveListingType(json['category']),
      dailyRate: (json['daily_rate'])?.toDouble(),
      salePrice: (json['sale_price'])?.toDouble(),
      isAvailable: json['status'] == null || json['status'] == 'available',
      location: json['location'],
      transmission: json['transmission'],
      fuelType: json['fuel_type'],
      seats: json['seats'],
      description: json['notes'],
    );
  }
}