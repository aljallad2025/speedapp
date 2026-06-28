import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/app_user_model.dart';

class AuthService {
  final _client = SupabaseConfig.client;

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
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId != null) {
      // ⚠️ تأكد جدول users فيه نفس هذي الأعمدة بالضبط
      await _client.from('users').upsert({
        'id': userId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
      });
    }

    return response;
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<AppUserModel?> getCurrentUserProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final row =
        await _client.from('users').select().eq('id', uid).maybeSingle();
    if (row == null) return null;
    return AppUserModel.fromJson(row);
  }
}
