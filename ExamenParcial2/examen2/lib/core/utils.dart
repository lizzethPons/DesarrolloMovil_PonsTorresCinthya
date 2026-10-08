import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centro por defecto del mapa (Ciudad de Guatemala)
const defaultCenter = LatLng(14.6349, -90.5069);

String friendlyError(Object e) {
  final s = e.toString();
  if (s.contains('SocketException') ||
      s.contains('ClientException') ||
      s.contains('Failed host lookup')) {
    return 'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.';
  }
  if (e is AuthException) {
    if (e.message.contains('Invalid login')) {
      return 'Correo o contraseña incorrectos';
    }
    if (e.message.contains('already registered')) {
      return 'Ese correo ya está registrado';
    }
    return e.message;
  }
  if (e is PostgrestException) return e.message;
  return s.replaceFirst('Exception: ', '');
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
    ));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(
              minimumSize: const Size(110, 44),
              backgroundColor: Theme.of(ctx).colorScheme.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return r ?? false;
}