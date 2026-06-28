/// ⚠️ هذا جدول جديد `booking_requests` - لازم ننشئه بـ migration (موجود SQL بالـ README)
/// الفكرة: الحجز من الموبايل يدخل كـ "طلب" بس، والموظف بالـ ERP يراجعه
/// ويحوّله لعقد إيجار فعلي (نفس مبدأ Quotation -> Convert to Invoice الموجود بالنظام)
class BookingRequestModel {
  final String? id;
  final String carId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // pending | confirmed | rejected | converted
  final String? notes;
  final DateTime? createdAt;

  BookingRequestModel({
    this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.status = 'pending',
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toInsertJson() => {
        'car_id': carId,
        'user_id': userId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': status,
        'notes': notes,
      };

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'].toString(),
      carId: json['car_id'].toString(),
      userId: json['user_id'].toString(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
