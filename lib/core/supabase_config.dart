import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration.
/// IMPORTANT: نفس مشروع Supabase اللي تستخدمه لوحة التحكم (ERP)
/// نفس جداول cars و users الحالية - لا تنشئ مشروع جديد.
class SupabaseConfig {
  SupabaseConfig._();

  // TODO: عبّي هذي القيم من ERP env (.env.local -> NEXT_PUBLIC_SUPABASE_URL / ANON_KEY)
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
