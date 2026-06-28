import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/car_model.dart';
import '../../models/booking_request_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final CarModel car;
  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _bookingService = BookingService();
  final _authService = AuthService();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _submitting = false;

  int get _days {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice {
    final rate = widget.car.dailyRate ?? 0;
    return rate * _days;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? now : (_startDate ?? now).add(const Duration(days: 1)),
      firstDate: isStart ? now : (_startDate ?? now).add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null || _days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر تاريخ البداية والنهاية')),
      );
      return;
    }

    final userId = _authService.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجل دخول أولاً')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _bookingService.createBookingRequest(
        BookingRequestModel(
          carId: widget.car.id,
          userId: userId,
          startDate: _startDate!,
          endDate: _endDate!,
          notes: _notesController.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب الحجز! بنتواصل معك لتأكيده'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ، حاول مرة ثانية')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'اختر التاريخ';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: Text('حجز ${widget.car.displayName}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _DateBox(
                    label: 'من',
                    value: _fmt(_startDate),
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateBox(
                    label: 'إلى',
                    value: _fmt(_endDate),
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
              ),
            ),
            const SizedBox(height: 20),
            if (_days > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$_days يوم'),
                    Text(
                      'BD ${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.speedRed,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('إرسال طلب الحجز'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.greyDark)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
