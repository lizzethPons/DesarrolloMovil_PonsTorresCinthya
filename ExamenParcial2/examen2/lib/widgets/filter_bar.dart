import 'package:flutter/material.dart';
import 'package:examen2/controllers/places_controller.dart';
import 'package:examen2/core/categories.dart';

class FilterBar extends StatelessWidget {
  final PlacesController ctrl;
  const FilterBar({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: ctrl.setQuery,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListenableBuilder(
            listenable: ctrl,
            builder: (context, _) => ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip(context, null, 'Todos', Icons.apps_rounded),
                for (final c in categories) _chip(context, c.key, c.label, c.icon),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String? key, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: ctrl.category == key,
        showCheckmark: false,
        onSelected: (_) => ctrl.setCategory(key),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}