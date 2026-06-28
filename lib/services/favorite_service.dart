import '../core/supabase_config.dart';

/// ⚠️ جدول `favorites` افتراض أعمدته: id, user_id, car_id, created_at
class FavoriteService {
  final _client = SupabaseConfig.client;

  Future<bool> isFavorite(String userId, String carId) async {
    final row = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('car_id', carId)
        .maybeSingle();
    return row != null;
  }

  Future<void> toggleFavorite(String userId, String carId) async {
    final existing = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('car_id', carId)
        .maybeSingle();

    if (existing != null) {
      await _client.from('favorites').delete().eq('id', existing['id']);
    } else {
      await _client
          .from('favorites')
          .insert({'user_id': userId, 'car_id': carId});
    }
  }

  Future<List<String>> getFavoriteCarIds(String userId) async {
    final rows = await _client
        .from('favorites')
        .select('car_id')
        .eq('user_id', userId);
    return (rows as List).map((r) => r['car_id'].toString()).toList();
  }
}
