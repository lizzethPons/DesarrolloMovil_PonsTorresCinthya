import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sucursal.dart';

class SucursalService {
  static final _client = Supabase.instance.client;

  /// Lista en tiempo real.
  static Stream<List<Sucursal>> stream() {
    return _client
        .from('sucursales')
        .stream(primaryKey: ['id'])
        .order('id')
        .map((rows) => rows.map(Sucursal.fromMap).toList());
  }

  static Future<void> add(Sucursal s) async {
    await _client.from('sucursales').insert(s.toMap());
  }

  static Future<void> delete(int id) async {
    await _client.from('sucursales').delete().eq('id', id);
  }
}