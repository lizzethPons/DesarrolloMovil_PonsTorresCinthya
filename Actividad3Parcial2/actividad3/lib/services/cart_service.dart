import 'package:flutter/foundation.dart';
import '../models/pizza.dart';

class CartItem {
  final Pizza pizza;
  int cantidad;
  CartItem(this.pizza, [this.cantidad = 1]);

  double get subtotal => pizza.precio * cantidad;
}

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get count => _items.values.fold(0, (s, i) => s + i.cantidad);
  double get total => _items.values.fold(0.0, (s, i) => s + i.subtotal);

  void add(Pizza p) {
    _items.update(
      p.id!,
      (i) {
        i.cantidad++;
        return i;
      },
      ifAbsent: () => CartItem(p),
    );
    notifyListeners();
  }

  void decrease(Pizza p) {
    final item = _items[p.id];
    if (item == null) return;
    if (item.cantidad > 1) {
      item.cantidad--;
    } else {
      _items.remove(p.id);
    }
    notifyListeners();
  }

  void remove(int id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}