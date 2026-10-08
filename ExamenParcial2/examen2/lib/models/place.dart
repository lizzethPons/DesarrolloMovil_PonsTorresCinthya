import 'package:latlong2/latlong.dart';

class Place {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double latitude;
  final double longitude;
  final String? photoUrl;

  Place({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory Place.fromMap(Map<String, dynamic> m) => Place(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String?,
        category: (m['category'] as String?) ?? 'otro',
        latitude: (m['latitude'] as num).toDouble(),
        longitude: (m['longitude'] as num).toDouble(),
        photoUrl: m['photo_url'] as String?,
      );
}