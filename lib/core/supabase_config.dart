import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://panlmbtbdsonlzhrqegp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhbmxtYnRiZHNvbmx6aHJxZWdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5MDU3NzgsImV4cCI6MjA4MzQ4MTc3OH0.Qn16l0q0uFR9Vnhe-zhl48vQl9znijUyDqx5cZLHYRs';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
