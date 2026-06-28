import '../core/supabase_config.dart';
import '../models/booking_request_model.dart';

class BookingService {
  final _client = SupabaseConfig.client;

  Future<void> createBookingRequest(BookingRequestModel request) async {
    await _client.from('booking_requests').insert(request.toInsertJson());
  }

  Future<List<BookingRequestModel>> getMyBookingRequests(
      String customerId) async {
    final rows = await _client
        .from('booking_requests')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => BookingRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// السيارات المحجوزة فعلياً (طلبات غير مرفوضة) بأي يوم يتداخل مع
  /// الفترة [start, end] - تستخدم لفلتر التواريخ الحقيقي بصفحة السيارات.
  Future<List<String>> getBookedCarIds({
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _client
        .from('booking_requests')
        .select('car_id')
        .neq('status', 'rejected')
        .lt('start_date', end.toIso8601String())
        .gt('end_date', start.toIso8601String());
    return (rows as List).map((r) => r['car_id'].toString()).toSet().toList();
  }
}