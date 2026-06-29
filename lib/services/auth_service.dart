import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/app_user_model.dart';

class AuthService {
  final _client = SupabaseConfig.client;
  static String? _cachedCustomerId;

  bool get isLoggedIn => _client.auth.currentUser != null;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    await _client.auth.signUp(email: email, password: password);
    final loginResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final userId = loginResponse.user?.id;
    if (userId != null) {
      await _linkOrCreateCustomer(
        authUserId: userId,
        fullName: fullName,
        email: email,
        phone: phone,
      );
    }
    return loginResponse;
  }

  Future<void> _linkOrCreateCustomer({
    required String authUserId,
    required String fullName,
    required String email,
    String? phone,
  }) async {
    Map<String, dynamic>? existing;
    if (phone != null && phone.isNotEmpty) {
      existing = await _client
          .from('customers')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();
    }
    existing ??= email.isNotEmpty
        ? await _client
            .from('customers')
            .select('id')
            .eq('email', email)
            .maybeSingle()
        : null;
    if (existing != null) {
      await _client
          .from('customers')
          .update({'auth_user_id': authUserId})
          .eq('id', existing['id']);
    } else {
      await _client.from('customers').insert({
        'auth_user_id': authUserId,
        'full_name': fullName,
        'email': email,
        'phone': (phone == null || phone.isEmpty) ? '-' : phone,
      });
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _cachedCustomerId = null;
  }

  Future<String?> getCurrentCustomerId() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    if (_cachedCustomerId != null) return _cachedCustomerId;
    final row = await _client
        .from('customers')
        .select('id')
        .eq('auth_user_id', uid)
        .maybeSingle();
    _cachedCustomerId = row?['id']?.toString();
    return _cachedCustomerId;
  }

  Future<AppUserModel?> getCurrentUserProfile() async {
    final customerId = await getCurrentCustomerId();
    if (customerId == null) return null;
    final row = await _client
        .from('customers')
        .select()
        .eq('id', customerId)
        .maybeSingle();
    if (row == null) return null;
    return AppUserModel.fromJson(row);
  }
}