import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:examen2/controllers/places_controller.dart';
import 'package:examen2/core/utils.dart';

class ProfileScreen extends StatelessWidget {
  final PlacesController ctrl;
  const ProfileScreen({super.key, required this.ctrl});

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Quieres salir de tu cuenta?',
      confirmText: 'Salir',
    );
    if (!ok) return;
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final scheme = Theme.of(context).colorScheme;
    final name = (user?.userMetadata?['name'] as String?)?.trim();
    final email = user?.email ?? '';
    final shown = (name != null && name.isNotEmpty) ? name : email;
    final initial = shown.isEmpty ? '?' : shown[0].toUpperCase();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 12),
        Center(
          child: CircleAvatar(
            radius: 52,
            backgroundColor: scheme.primary,
            child: Text(initial,
                style: const TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(shown,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        if (name != null && name.isNotEmpty)
          Center(
              child: Text(email, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(height: 28),
        ListenableBuilder(
          listenable: ctrl,
          builder: (context, _) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, color: scheme.primary, size: 36),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${ctrl.all.length}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Text('lugares guardados'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}