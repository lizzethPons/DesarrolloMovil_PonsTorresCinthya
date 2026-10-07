import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pizza.dart';

class PizzaService {
  static final _client = Supabase.instance.client;

  /// Lista en tiempo real.
  static Stream<List<Pizza>> stream() {
    return _client
        .from('pizzas')
        .stream(primaryKey: ['id'])
        .order('id')
        .map((rows) => rows.map(Pizza.fromMap).toList());
  }

  static Future<void> add(Pizza p) async {
    await _client.from('pizzas').insert(p.toMap());
  }

  static Future<void> update(Pizza p) async {
    await _client.from('pizzas').update(p.toMap()).eq('id', p.id!);
  }

  static Future<void> delete(int id) async {
    await _client.from('pizzas').delete().eq('id', id);
  }
}