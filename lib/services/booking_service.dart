import '../core/supabase_config.dart';
import '../models/booking_request_model.dart';

/// ⚠️ جدول جديد `booking_requests` - شوف SQL بالـ README عشان تنشئه
class BookingService {
  final _client = SupabaseConfig.client;

  Future<void> createBookingRequest(BookingRequestModel request) async {
    await _client.from('booking_requests').insert(request.toInsertJson());
  }

  Future<List<BookingRequestModel>> getMyBookingRequests(String userId) async {
    final rows = await _client
        .from('booking_requests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => BookingRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
