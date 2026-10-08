import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:examen2/controllers/places_controller.dart';
import 'package:examen2/core/categories.dart';
import 'package:examen2/core/utils.dart';
import 'package:examen2/models/place.dart';
import 'package:examen2/screens/place_form_screen.dart';
import 'package:examen2/services/location_service.dart';
import 'package:examen2/widgets/filter_bar.dart';

class MapScreen extends StatefulWidget {
  final PlacesController ctrl;
  const MapScreen({super.key, required this.ctrl});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _map = MapController();
  LatLng? _me;
  bool _ready = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate({bool showErrors = false}) async {
    setState(() => _locating = true);
    try {
      final p = await LocationService.current();
      if (!mounted) return;
      setState(() => _me = p);
      if (_ready) _map.move(p, 16);
    } catch (e) {
      if (mounted && showErrors) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showPlace(Place p) {
    final cat = categoryOf(p.category);
    final desc = p.description;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  p.photoUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 12),
            Row(children: [
              Icon(cat.icon, color: cat.color, size: 18),
              const SizedBox(width: 6),
              Text(cat.label, style: Theme.of(ctx).textTheme.labelLarge),
            ]),
            const SizedBox(height: 4),
            Text(p.name,
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (desc != null && desc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(desc),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                PlaceFormScreen.open(context, widget.ctrl, p);
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Editar lugar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: widget.ctrl,
      builder: (context, _) {
        final places = widget.ctrl.filtered;
        return Stack(
          children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: defaultCenter,
                initialZoom: 13,
                onMapReady: () {
                  _ready = true;
                  if (_me != null) _map.move(_me!, 16);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mis_lugares',
                ),
                MarkerLayer(markers: [
                  for (final p in places)
                    Marker(
                      point: p.latLng,
                      width: 46,
                      height: 46,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _showPlace(p),
                        child: Icon(Icons.location_on,
                            size: 46, color: categoryOf(p.category).color),
                      ),
                    ),
                ]),
                if (_me != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _me!,
                      width: 26,
                      height: 26,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6)
                          ],
                        ),
                      ),
                    ),
                  ]),
                const RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                elevation: 3,
                color: scheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: FilterBar(ctrl: widget.ctrl),
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 88,
              child: FloatingActionButton.small(
                heroTag: 'my-location',
                tooltip: 'Mi ubicación',
                onPressed: _locating ? null : () => _locate(showErrors: true),
                child: _locating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location_rounded),
              ),
            ),
          ],
        );
      },
    );
  }
}