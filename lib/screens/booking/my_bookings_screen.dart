import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/booking_request_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _bookingService = BookingService();
  final _authService = AuthService();
  List<BookingRequestModel> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final bookings = await _bookingService.getMyBookingRequests(userId);
      setState(() {
        _bookings = bookings;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _bookings = [];
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'converted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'converted':
        return 'تم التحويل لعقد';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد المراجعة';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authService.isLoggedIn) {
      return const Scaffold(
        body: Center(child: Text('سجل دخول لعرض حجوزاتك')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.speedRed))
          : _bookings.isEmpty
              ? const Center(child: Text('لا توجد حجوزات حتى الآن'))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.speedRed,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final b = _bookings[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${b.startDate.day}/${b.startDate.month} - ${b.endDate.day}/${b.endDate.month}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                if (b.notes != null && b.notes!.isNotEmpty)
                                  Text(b.notes!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.greyDark)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _statusColor(b.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusLabel(b.status),
                                style: const TextStyle(
                                    color: AppColors.white, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
