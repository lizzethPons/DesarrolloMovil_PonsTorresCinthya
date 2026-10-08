import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:examen2/core/utils.dart';
import 'package:examen2/services/location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _map = MapController();
  late LatLng? _point = widget.initial;
  LatLng? _me;
  bool _ready = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial == null) _locate();
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

  Future<void> _useMyLocation() async {
    await _locate(showErrors: true);
    if (_me != null && mounted) setState(() => _point = _me);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Elige la ubicación')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: widget.initial ?? defaultCenter,
              initialZoom: widget.initial != null ? 16 : 13,
              onMapReady: () {
                _ready = true;
                if (_me != null && widget.initial == null) _map.move(_me!, 16);
              },
              onTap: (tapPosition, point) => setState(() => _point = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mis_lugares',
              ),
              if (_me != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _me!,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ]),
              if (_point != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _point!,
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: Icon(Icons.location_on, size: 50, color: scheme.primary),
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
            right: 16,
            bottom: 100,
            child: FloatingActionButton.small(
              heroTag: 'picker-location',
              tooltip: 'Usar mi ubicación',
              onPressed: _locating ? null : _useMyLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: FilledButton(
              onPressed:
                  _point == null ? null : () => Navigator.pop(context, _point),
              child: Text(_point == null
                  ? 'Toca el mapa para elegir'
                  : 'Confirmar ubicación'),
            ),
          ),
        ],
      ),
    );
  }
}