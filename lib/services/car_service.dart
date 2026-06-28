import '../core/supabase_config.dart';
import '../models/car_model.dart';

class CarService {
  final _client = SupabaseConfig.client;

  /// يرجع كل السيارات. ممكن تفلتر بـ listingType: 'rent' | 'sale' | null (الكل)
  Future<List<CarModel>> getCars({String? listingType}) async {
    var query = _client.from('cars').select();

    if (listingType != null && listingType != 'all') {
      // 'both' لازم تطلع بكل الفلاتر
      query = query.or('listing_type.eq.$listingType,listing_type.eq.both');
    }

    final response = await query;
    return (response as List)
        .map((e) => CarModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CarModel?> getCarById(String id) async {
    final response =
        await _client.from('cars').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return CarModel.fromJson(response);
  }
}
