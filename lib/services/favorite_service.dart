import '../core/supabase_config.dart';

/// جدول `favorites` الحقيقي: id, customer_id, car_id, created_at
/// (customer_id يشير لجدول customers، مش لـ auth.users مباشرة)
class FavoriteService {
  final _client = SupabaseConfig.client;

  Future<bool> isFavorite(String customerId, String carId) async {
    final row = await _client
        .from('favorites')
        .select('id')
        .eq('customer_id', customerId)
        .eq('car_id', carId)
        .maybeSingle();
    return row != null;
  }

  Future<void> toggleFavorite(String customerId, String carId) async {
    final existing = await _client
        .from('favorites')
        .select('id')
        .eq('customer_id', customerId)
        .eq('car_id', carId)
        .maybeSingle();

    if (existing != null) {
      await _client.from('favorites').delete().eq('id', existing['id']);
    } else {
      await _client
          .from('favorites')
          .insert({'customer_id': customerId, 'car_id': carId});
    }
  }

  Future<List<String>> getFavoriteCarIds(String customerId) async {
    final rows = await _client
        .from('favorites')
        .select('car_id')
        .eq('customer_id', customerId);
    return (rows as List).map((r) => r['car_id'].toString()).toList();
  }
}