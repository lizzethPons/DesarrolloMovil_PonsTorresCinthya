import 'package:flutter/material.dart';
import '../../models/pizza.dart';
import '../../services/cart_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pizza_image.dart';

class PizzaDetailScreen extends StatelessWidget {
  final Pizza pizza;
  const PizzaDetailScreen({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pizza.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PizzaImage(
                url: pizza.imagenUrl,
                height: 240,
                width: double.infinity),
            const SizedBox(height: 16),
            Text(pizza.nombre,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (pizza.categoria != null && pizza.categoria!.isNotEmpty)
              Chip(
                label: Text(pizza.categoria!),
                backgroundColor: AppTheme.orangeLight,
                side: BorderSide.none,
              ),
            const SizedBox(height: 8),
            Text('\$${pizza.precio.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.orange)),
            const SizedBox(height: 16),
            const Text('Descripción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              (pizza.descripcion == null || pizza.descripcion!.isEmpty)
                  ? 'Sin descripción'
                  : pizza.descripcion!,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Agregar al carrito'),
              onPressed: () {
                CartService.instance.add(pizza);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${pizza.nombre} agregada')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}