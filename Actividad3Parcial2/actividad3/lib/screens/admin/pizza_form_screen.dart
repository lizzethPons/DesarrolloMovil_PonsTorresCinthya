import 'package:flutter/material.dart';
import '../../models/pizza.dart';
import '../../services/pizza_service.dart';

class PizzaFormScreen extends StatefulWidget {
  final Pizza? pizza; // null = agregar, con valor = editar
  const PizzaFormScreen({super.key, this.pizza});

  @override
  State<PizzaFormScreen> createState() => _PizzaFormScreenState();
}

class _PizzaFormScreenState extends State<PizzaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.pizza?.nombre);
  late final _descripcion =
      TextEditingController(text: widget.pizza?.descripcion);
  late final _precio = TextEditingController(
      text: widget.pizza == null ? '' : widget.pizza!.precio.toString());
  late final _categoria = TextEditingController(text: widget.pizza?.categoria);
  late final _imagen = TextEditingController(text: widget.pizza?.imagenUrl);
  bool _saving = false;

  bool get _editing => widget.pizza != null;

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _categoria.dispose();
    _imagen.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final pizza = Pizza(
      id: widget.pizza?.id,
      nombre: _nombre.text.trim(),
      descripcion: _nullIfEmpty(_descripcion.text),
      precio: double.parse(_precio.text.trim().replaceAll(',', '.')),
      categoria: _nullIfEmpty(_categoria.text),
      imagenUrl: _nullIfEmpty(_imagen.text),
    );

    try {
      if (_editing) {
        await PizzaService.update(pizza);
      } else {
        await PizzaService.add(pizza);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Editar pizza' : 'Nueva pizza')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcion,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precio,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Precio'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Ingresa un precio válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoria,
                decoration: const InputDecoration(
                    labelText: 'Categoría (ej. Clásica, Especial)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imagen,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'URL de la imagen'),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_editing ? 'Guardar cambios' : 'Agregar pizza',
                        style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}