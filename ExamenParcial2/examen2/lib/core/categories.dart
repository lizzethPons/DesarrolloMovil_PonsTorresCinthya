import 'package:flutter/material.dart';

class PlaceCategory {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const PlaceCategory(this.key, this.label, this.icon, this.color);
}

const categories = <PlaceCategory>[
  PlaceCategory('casa', 'Casa', Icons.home_rounded, Color(0xFFE5739B)),
  PlaceCategory('comida', 'Comida', Icons.restaurant_rounded, Color(0xFFF59E0B)),
  PlaceCategory('estudio', 'Estudio', Icons.school_rounded, Color(0xFF6366F1)),
  PlaceCategory('diversion', 'Diversión', Icons.celebration_rounded, Color(0xFF8B5CF6)),
  PlaceCategory('deporte', 'Deporte', Icons.fitness_center_rounded, Color(0xFF10B981)),
  PlaceCategory('otro', 'Otro', Icons.place_rounded, Color(0xFF64748B)),
];

PlaceCategory categoryOf(String key) =>
    categories.firstWhere((c) => c.key == key, orElse: () => categories.last);