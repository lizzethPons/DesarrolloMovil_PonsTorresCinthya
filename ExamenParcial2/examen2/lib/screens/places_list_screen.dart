import 'package:flutter/material.dart';
import 'package:examen2/controllers/places_controller.dart';
import 'package:examen2/core/utils.dart';
import 'package:examen2/screens/place_form_screen.dart';
import 'package:examen2/widgets/filter_bar.dart';
import 'package:examen2/widgets/place_card.dart';

class PlacesListScreen extends StatelessWidget {
  final PlacesController ctrl;
  const PlacesListScreen({super.key, required this.ctrl});

  Future<void> _delete(BuildContext context, place) async {
    final ok = await confirmDialog(
      context,
      title: 'Eliminar lugar',
      message: '¿Seguro que quieres eliminar "${place.name}"? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
    );
    if (!ok) return;
    try {
      await ctrl.remove(place);
      if (context.mounted) showSnack(context, 'Lugar eliminado');
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final places = ctrl.filtered;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: FilterBar(ctrl: ctrl),
            ),
            Expanded(child: _body(context, places)),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, List places) {
    if (ctrl.loading && ctrl.all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.error != null && ctrl.all.isEmpty) {
      return _message(context, Icons.wifi_off_rounded, ctrl.error!,
          action: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
            onPressed: ctrl.load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ));
    }
    if (places.isEmpty) {
      return _message(
        context,
        Icons.favorite_border_rounded,
        ctrl.all.isEmpty
            ? 'Aún no tienes lugares.\nToca "Agregar" para guardar el primero.'
            : 'No encontramos lugares con ese filtro.',
      );
    }
    return RefreshIndicator(
      onRefresh: ctrl.load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: places.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${ctrl.all.length} ${ctrl.all.length == 1 ? 'lugar guardado' : 'lugares guardados'}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            );
          }
          final p = places[i - 1];
          return PlaceCard(
            place: p,
            onTap: () => PlaceFormScreen.open(context, ctrl, p),
            onDelete: () => _delete(context, p),
          );
        },
      ),
    );
  }

  Widget _message(BuildContext context, IconData icon, String text,
      {Widget? action}) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }
}