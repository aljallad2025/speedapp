import '../core/supabase_config.dart';
import '../models/car_model.dart';

class CarService {
  final _client = SupabaseConfig.client;

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

  /// المناطق الحقيقية الموجودة بقاعدة البيانات (عمود location) - لبناء
  /// قائمة فلتر المناطق من بيانات فعلية لا قائمة ثابتة بالكود.
  Future<List<String>> getDistinctLocations() async {
    final rows = await _client.from('cars').select('location');
    final set = <String>{};
    for (final r in (rows as List)) {
      final loc = r['location'];
      if (loc != null && loc.toString().trim().isNotEmpty) {
        set.add(loc.toString());
      }
    }
    final list = set.toList()..sort();
    return list;
  }
}