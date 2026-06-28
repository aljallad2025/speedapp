/// User profile model
/// ⚠️ مبني على افتراضات لجدول `users` - تحتاج تأكيد من schema الحقيقي
class AppUserModel {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;

  AppUserModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? json['name'],
      email: json['email'],
      phone: json['phone'] ?? json['mobile'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
      };
}
