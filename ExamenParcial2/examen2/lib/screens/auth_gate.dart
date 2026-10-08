import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:examen2/screens/home_shell.dart';
import 'package:examen2/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snap) {
        final session = snap.data?.session ?? auth.currentSession;
        return session == null ? const LoginScreen() : const HomeShell();
      },
    );
  }
}