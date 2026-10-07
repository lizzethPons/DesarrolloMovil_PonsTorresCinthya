import 'package:flutter/material.dart';
import '../../models/pizza.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/pizza_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pizza_image.dart';
import 'cart_screen.dart';
import 'pizza_detail_screen.dart';
import '../sucursales_map_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuestro menú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Sucursales',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SucursalesMapScreen(isAdmin: false),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: cart,
            builder: (context, _) => Badge(
              isLabelVisible: cart.count > 0,
              label: Text('${cart.count}'),
              offset: const Offset(-4, 4),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              cart.clear();
              AuthService.logout();
            },
          ),
        ],
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
            return const Center(child: Text('Aún no hay pizzas disponibles'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pizzas.length,
            itemBuilder: (context, i) {
              final p = pizzas[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PizzaDetailScreen(pizza: p)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        PizzaImage(url: p.imagenUrl, height: 90, width: 90),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.nombre,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              if (p.categoria != null &&
                                  p.categoria!.isNotEmpty)
                                Text(p.categoria!,
                                    style: const TextStyle(
                                        color: AppTheme.orange)),
                              const SizedBox(height: 4),
                              Text('\$${p.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                              backgroundColor: AppTheme.orange),
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            cart.add(p);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                  duration: const Duration(seconds: 1),
                                  content:
                                      Text('${p.nombre} agregada al carrito')));
                          },
                        ),
                      ],
                    ),
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