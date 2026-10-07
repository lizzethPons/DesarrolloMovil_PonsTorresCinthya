import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Devuelve true si ya quedó con sesión iniciada.
  static Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    final user = res.user;
    if (user != null && res.session != null) {
      try {
        await _client.from('profiles').upsert(
          {
            'id': user.id,
            'email': email,
            'username': username,
            'role': 'cliente',
          },
          onConflict: 'id',
          ignoreDuplicates: true,
        );
      } catch (_) {
        // Si ya existe (trigger) o la RLS lo bloquea, seguimos.
      }
    }
    return res.session != null;
  }

  static Future<void> logout() async => _client.auth.signOut();

  static Future<String> getRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return 'cliente';
    final data = await _client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    return (data?['role'] as String?) ?? 'cliente';
  }
}