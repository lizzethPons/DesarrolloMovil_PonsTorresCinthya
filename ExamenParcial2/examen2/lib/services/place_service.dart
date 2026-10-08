import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:examen2/models/place.dart';

class PlaceService {
  final _db = Supabase.instance.client;
  static const _bucket = 'place-photos';

  Future<List<Place>> fetch() async {
    final data =
        await _db.from('places').select().order('created_at', ascending: false);
    return (data as List)
        .map((e) => Place.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await _db.from('places').insert(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _db.from('places').update(data).eq('id', id);
  }

  Future<void> delete(Place p) async {
    await _db.from('places').delete().eq('id', p.id);
    final url = p.photoUrl;
    if (url != null) {
      final marker = '/$_bucket/';
      final i = url.indexOf(marker);
      if (i != -1) {
        try {
          await _db.storage.from(_bucket).remove([url.substring(i + marker.length)]);
        } catch (_) {}
      }
    }
  }

  Future<String> uploadPhoto(Uint8List bytes) async {
    final uid = _db.auth.currentUser!.id;
    final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _db.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return _db.storage.from(_bucket).getPublicUrl(path);
  }
}