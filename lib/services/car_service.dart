import '../core/supabase_config.dart';
import '../models/car_model.dart';

class CarService {
  final _client = SupabaseConfig.client;

  /// يرجع كل السيارات. الفلترة (rent/sale) تصير محلياً بالتطبيق
  /// عشان عمود listing_type ممكن يكون غير موجود بعد بقاعدة البيانات
  /// (شغّل migration.sql لو تبي الفلترة الحقيقية).
  Future<List<CarModel>> getCars({String? listingType}) async {
    final response = await _client.from('cars').select();
    final cars = (response as List)
        .map((e) => CarModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (listingType == null || listingType == 'all') return cars;
    if (listingType == 'rent') return cars.where((c) => c.isForRent).toList();
    if (listingType == 'sale') return cars.where((c) => c.isForSale).toList();
    return cars;
  }

  Future<CarModel?> getCarById(String id) async {
    final response =
        await _client.from('cars').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return CarModel.fromJson(response);
  }
}
