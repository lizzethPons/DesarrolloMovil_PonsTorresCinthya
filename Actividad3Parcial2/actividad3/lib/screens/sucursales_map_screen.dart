import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/sucursal.dart';
import '../services/sucursal_service.dart';
import '../theme/app_theme.dart';

class SucursalesMapScreen extends StatefulWidget {
  final bool isAdmin;
  const SucursalesMapScreen({super.key, this.isAdmin = false});

  @override
  State<SucursalesMapScreen> createState() => _SucursalesMapScreenState();
}

class _SucursalesMapScreenState extends State<SucursalesMapScreen> {
  // Cambia estas coordenadas por la zona donde quieres que abra el mapa.
  static const LatLng _centroInicial = LatLng(14.6349, -90.5069);

  final _mapController = MapController();
  late final Stream<List<Sucursal>> _stream = SucursalService.stream();
  LatLng? _pendiente; // punto marcado mientras el admin llena el formulario

  void _msg(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _onMapTap(LatLng punto) async {
    if (!widget.isAdmin) return;

    setState(() => _pendiente = punto);
    final nueva = await showDialog<Sucursal>(
      context: context,
      builder: (_) => _NuevaSucursalDialog(punto: punto),
    );
    if (mounted) setState(() => _pendiente = null);
    if (nueva == null) return;

    try {
      await SucursalService.add(nueva);
      _msg('Sucursal agregada');
    } catch (e) {
      _msg('No se pudo guardar: $e');
    }
  }

  Future<void> _eliminar(Sucursal s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar sucursal'),
        content: Text('¿Seguro que quieres eliminar "${s.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await SucursalService.delete(s.id!);
      _msg('Sucursal eliminada');
    } catch (e) {
      _msg('No se pudo eliminar: $e');
    }
  }

  void _showInfo(Sucursal s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store, color: AppTheme.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.nombre,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(s.direccion)),
              ],
            ),
            if (s.telefono != null && s.telefono!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(s.telefono!),
                ],
              ),
            ],
            if (widget.isAdmin) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar sucursal'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _eliminar(s);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isAdmin ? 'Administrar sucursales' : 'Nuestras sucursales'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centroInicial,
              initialZoom: 13,
              onTap: (tapPosition, punto) => _onMapTap(punto),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // Cambia esto por el applicationId de tu app
                // (android/app/build.gradle).
                userAgentPackageName: 'com.example.pizzapp',
              ),
              StreamBuilder<List<Sucursal>>(
                stream: _stream,
                builder: (context, snap) {
                  final lista = snap.data ?? [];
                  return MarkerLayer(
                    markers: [
                      for (final s in lista)
                        Marker(
                          point: LatLng(s.latitud, s.longitud),
                          width: 48,
                          height: 48,
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => _showInfo(s),
                            child: const Icon(Icons.location_on,
                                size: 48, color: AppTheme.orange),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (_pendiente != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pendiente!,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on,
                          size: 48, color: Colors.red),
                    ),
                  ],
                ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (widget.isAdmin)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                color: Colors.white,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app, color: AppTheme.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Toca el mapa para agregar una sucursal'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Formulario que aparece al tocar un punto del mapa (solo admin).
class _NuevaSucursalDialog extends StatefulWidget {
  final LatLng punto;
  const _NuevaSucursalDialog({required this.punto});

  @override
  State<_NuevaSucursalDialog> createState() => _NuevaSucursalDialogState();
}

class _NuevaSucursalDialogState extends State<_NuevaSucursalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _telefono.dispose();
    super.dispose();
  }

  String? _requerido(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Sucursal(
        nombre: _nombre.text.trim(),
        direccion: _direccion.text.trim(),
        latitud: widget.punto.latitude,
        longitud: widget.punto.longitude,
        telefono:
            _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva sucursal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ubicación: ${widget.punto.latitude.toStringAsFixed(5)}, '
                '${widget.punto.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _requerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: _requerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Teléfono (opcional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}