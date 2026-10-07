import 'package:flutter/material.dart';
import '../../models/pizza.dart';
import '../../services/auth_service.dart';
import '../../services/pizza_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pizza_image.dart';
import 'pizza_form_screen.dart';
import '../sucursales_map_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Pizza p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar pizza'),
        content: Text('¿Seguro que quieres eliminar "${p.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok == true) {
      try {
        await PizzaService.delete(p.id!);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Sucursales',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SucursalesMapScreen(isAdmin: true),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: AuthService.logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar pizza'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PizzaFormScreen()),
        ),
      ),
      body: StreamBuilder<List<Pizza>>(
        stream: PizzaService.stream(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.orange));
          }
          final pizzas = snap.data!;
          if (pizzas.isEmpty) {
            return const Center(child: Text('No hay pizzas. ¡Agrega la primera!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: pizzas.length,
            itemBuilder: (context, i) {
              final p = pizzas[i];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading:
                      PizzaImage(url: p.imagenUrl, height: 56, width: 56),
                  title: Text(p.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${p.categoria ?? 'Sin categoría'} • \$${p.precio.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.orange),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PizzaFormScreen(pizza: p)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, p),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}