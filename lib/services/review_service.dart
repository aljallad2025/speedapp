import '../core/supabase_config.dart';
import '../models/review_model.dart';

/// ⚠️ جدول `reviews` افتراض أعمدته: id, car_id, user_id, rating, comment, created_at
class ReviewService {
  final _client = SupabaseConfig.client;

  Future<List<ReviewModel>> getReviewsForCar(String carId) async {
    final rows = await _client
        .from('reviews')
        .select()
        .eq('car_id', carId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addReview({
    required String carId,
    required String userId,
    required double rating,
    String? comment,
  }) async {
    await _client.from('reviews').insert({
      'car_id': carId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<double> getAverageRating(String carId) async {
    final reviews = await getReviewsForCar(carId);
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(0, (a, r) => a + r.rating);
    return sum / reviews.length;
  }
}
