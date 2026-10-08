import 'package:flutter/foundation.dart';
import 'package:examen2/core/utils.dart';
import 'package:examen2/models/place.dart';
import 'package:examen2/services/place_service.dart';

class PlacesController extends ChangeNotifier {
  final service = PlaceService();

  List<Place> all = [];
  bool loading = false;
  String? error;
  String query = '';
  String? category;

  List<Place> get filtered => all.where((p) {
        final okName = p.name.toLowerCase().contains(query.toLowerCase());
        final okCat = category == null || p.category == category;
        return okName && okCat;
      }).toList();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      all = await service.fetch();
    } catch (e) {
      error = friendlyError(e);
    }
    loading = false;
    notifyListeners();
  }

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void setCategory(String? c) {
    category = c;
    notifyListeners();
  }

  Future<void> remove(Place p) async {
    await service.delete(p);
    all.removeWhere((e) => e.id == p.id);
    notifyListeners();
  }
}