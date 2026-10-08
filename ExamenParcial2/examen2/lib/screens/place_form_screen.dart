import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:examen2/controllers/places_controller.dart';
import 'package:examen2/core/categories.dart';
import 'package:examen2/core/utils.dart';
import 'package:examen2/models/place.dart';
import 'package:examen2/screens/location_picker_screen.dart';

class PlaceFormScreen extends StatefulWidget {
  final PlacesController ctrl;
  final Place? place;
  const PlaceFormScreen({super.key, required this.ctrl, this.place});

  static Future<void> open(BuildContext context, PlacesController ctrl,
          [Place? place]) =>
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PlaceFormScreen(ctrl: ctrl, place: place)),
      );

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.place?.name);
  late final _desc = TextEditingController(text: widget.place?.description);
  late String _category = widget.place?.category ?? 'otro';
  late LatLng? _point = widget.place?.latLng;
  late final String? _photoUrl = widget.place?.photoUrl;
  Uint8List? _photoBytes;
  bool _saving = false;

  bool get _editing => widget.place != null;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1280,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (mounted) setState(() => _photoBytes = bytes);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  Future<void> _pickLocation() async {
    final r = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen(initial: _point)),
    );
    if (r != null) setState(() => _point = r);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_photoBytes == null && _photoUrl == null) {
      showSnack(context, 'Agrega una foto del lugar', error: true);
      return;
    }
    if (_point == null) {
      showSnack(context, 'Elige la ubicación en el mapa', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      String? url = _photoUrl;
      if (_photoBytes != null) {
        url = await widget.ctrl.service.uploadPhoto(_photoBytes!);
      }
      final data = {
        'name': _name.text.trim(),
        'description': _desc.text.trim(),
        'category': _category,
        'latitude': _point!.latitude,
        'longitude': _point!.longitude,
        'photo_url': url,
      };
      if (_editing) {
        await widget.ctrl.service.update(widget.place!.id, data);
      } else {
        await widget.ctrl.service.insert(data);
      }
      await widget.ctrl.load();
      if (!mounted) return;
      showSnack(context, _editing ? 'Lugar actualizado' : 'Lugar guardado');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    Widget photoArea;
    if (_photoBytes != null) {
      photoArea = Image.memory(
        _photoBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (_photoUrl != null) {
      photoArea = Image.network(
        _photoUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else {
      photoArea = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_rounded, size: 40, color: scheme.primary),
          const SizedBox(height: 8),
          const Text('Toca para elegir una foto'),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Editar lugar' : 'Nuevo lugar')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Semantics(
              button: true,
              label: 'Elegir foto del lugar',
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _pickPhoto,
                child: Container(
                  height: 190,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: photoArea,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre del lugar',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Escribe un nombre'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desc,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Categoría', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18, color: c.color),
                    label: Text(c.label),
                    selected: _category == c.key,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _category = c.key),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Ubicación', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_point != null) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _pickLocation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 150,
                    child: IgnorePointer(
                      child: FlutterMap(
                        key: ValueKey(_point),
                        options: MapOptions(
                          initialCenter: _point!,
                          initialZoom: 16,
                          interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.mis_lugares',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              point: _point!,
                              width: 40,
                              height: 40,
                              alignment: Alignment.topCenter,
                              child: Icon(Icons.location_on,
                                  size: 40, color: scheme.primary),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map_rounded),
              label: Text(_point == null
                  ? 'Elegir en el mapa'
                  : 'Cambiar ubicación'),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(_editing ? 'Guardar cambios' : 'Guardar lugar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}