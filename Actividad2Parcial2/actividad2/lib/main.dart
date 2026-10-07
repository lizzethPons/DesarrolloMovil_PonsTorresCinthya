import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rsnsmqaokmsdzhnzzrta.supabase.co',
    anonKey: 'sb_publishable_BEStXi1GB33jQaLPx6Q0sw_4Zw4FmAO',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canciones App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const CancionesPage(),
    );
  }
}

class CancionesPage extends StatefulWidget {
  const CancionesPage({super.key});

  @override
  State<CancionesPage> createState() => _CancionesPageState();
}

class _CancionesPageState extends State<CancionesPage> {
  final Stream<List<Map<String, dynamic>>> _cancionesStream =
      supabase.from('canciones').stream(primaryKey: ['id']);

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Cambiar estado de favorita
  Future<void> _toggleFavorita(int id, bool estadoActual) async {
    try {
      await supabase.from('canciones').update({
        'favorita': !estadoActual,
      }).eq('id', id);
    } catch (e) {
      _mostrarSnackBar('Error al actualizar favorita: $e', isError: true);
    }
  }

  // Confirmar y Eliminar
  Future<void> _confirmarEliminacion(
      BuildContext context, int id, String titulo) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Eliminar canción'),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar "$titulo"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await supabase.from('canciones').delete().eq('id', id);
        _mostrarSnackBar('Canción eliminada correctamente');
      } catch (e) {
        _mostrarSnackBar('Error al eliminar: $e', isError: true);
      }
    }
  }

  // Abrir Modal de Formulario (Crear o Editar)
  void _mostrarFormularioCancion({Map<String, dynamic>? cancionExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _FormularioCancionModal(
            cancionExistente: cancionExistente,
            onGuardar: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _mostrarSnackBar(String mensaje, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Biblioteca',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de Búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por título o artista...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Lista de Canciones en Realtime
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _cancionesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error de conexión:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                }

                List<Map<String, dynamic>> canciones = snapshot.data ?? [];

                // Filtrar por búsqueda
                if (_searchQuery.isNotEmpty) {
                  canciones = canciones.where((cancion) {
                    final titulo =
                        (cancion['titulo'] ?? '').toString().toLowerCase();
                    final artista =
                        (cancion['artista'] ?? '').toString().toLowerCase();
                    return titulo.contains(_searchQuery) ||
                        artista.contains(_searchQuery);
                  }).toList();
                }

                // Ordenar: Favoritos primero, luego por id descendente (más nuevos arriba)
                canciones.sort((a, b) {
                  final bool favA = a['favorita'] ?? false;
                  final bool favB = b['favorita'] ?? false;
                  if (favA == favB) {
                    final int idA = a['id'] ?? 0;
                    final int idB = b['id'] ?? 0;
                    return idB.compareTo(idA);
                  }
                  return favB ? 1 : -1;
                });

                if (canciones.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.music_off_outlined
                              : Icons.search_off_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay canciones en tu biblioteca'
                              : 'No se encontraron coincidencias',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: canciones.length,
                  itemBuilder: (context, index) {
                    final cancion = canciones[index];
                    final int id = cancion['id'];
                    final bool esFavorita = cancion['favorita'] ?? false;

                    // Formato de duración en mm:ss
                    final int? duracionSeg = cancion['duracion_seg'];
                    String duracionTexto = '';
                    if (duracionSeg != null && duracionSeg > 0) {
                      final min = duracionSeg ~/ 60;
                      final seg = (duracionSeg % 60).toString().padLeft(2, '0');
                      duracionTexto = '${min}:${seg} min';
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: esFavorita
                              ? Colors.amber.shade100
                              : Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                          child: Icon(
                            esFavorita
                                ? Icons.star_rounded
                                : Icons.music_note_rounded,
                            color: esFavorita
                                ? Colors.amber.shade900
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          cancion['titulo'] ?? 'Sin título',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              cancion['artista'] ?? 'Artista desconocido',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (cancion['album'] != null &&
                                    cancion['album'].toString().isNotEmpty)
                                  Text(
                                    cancion['album'],
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                  ),
                                if (cancion['anio'] != null)
                                  Text(
                                    '•  ${cancion['anio']}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                  ),
                                if (duracionTexto.isNotEmpty)
                                  Text(
                                    '•  $duracionTexto',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                esFavorita
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: esFavorita ? Colors.redAccent : null,
                              ),
                              tooltip: esFavorita
                                  ? 'Quitar de favoritos'
                                  : 'Marcar como favorita',
                              onPressed: () => _toggleFavorita(id, esFavorita),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (value) {
                                if (value == 'editar') {
                                  _mostrarFormularioCancion(
                                      cancionExistente: cancion);
                                } else if (value == 'eliminar') {
                                  _confirmarEliminacion(
                                    context,
                                    id,
                                    cancion['titulo'] ?? '',
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 20),
                                      SizedBox(width: 12),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline,
                                          size: 20, color: Colors.redAccent),
                                      SizedBox(width: 12),
                                      Text('Eliminar',
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioCancion(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Canción'),
      ),
    );
  }
}

// Widget Modal para Agregar / Editar Canciones
class _FormularioCancionModal extends StatefulWidget {
  final Map<String, dynamic>? cancionExistente;
  final VoidCallback onGuardar;

  const _FormularioCancionModal({
    this.cancionExistente,
    required this.onGuardar,
  });

  @override
  State<_FormularioCancionModal> createState() =>
      __FormularioCancionModalState();
}

class __FormularioCancionModalState extends State<_FormularioCancionModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _artistaController;
  late TextEditingController _albumController;
  late TextEditingController _anioController;
  late TextEditingController _duracionController;
  bool _favorita = false;
  bool _cargando = false;

  bool get esEdicion => widget.cancionExistente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cancionExistente;
    _tituloController = TextEditingController(text: c?['titulo'] ?? '');
    _artistaController = TextEditingController(text: c?['artista'] ?? '');
    _albumController = TextEditingController(text: c?['album'] ?? '');
    _anioController =
        TextEditingController(text: c?['anio']?.toString() ?? '');
    _duracionController =
        TextEditingController(text: c?['duracion_seg']?.toString() ?? '');
    _favorita = c?['favorita'] ?? false;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _artistaController.dispose();
    _albumController.dispose();
    _anioController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final String titulo = _tituloController.text.trim();
    final String artista = _artistaController.text.trim();
    final String? album =
        _albumController.text.trim().isEmpty ? null : _albumController.text.trim();
    final int? anio = int.tryParse(_anioController.text.trim());
    final int? duracion = int.tryParse(_duracionController.text.trim());

    final datos = {
      'titulo': titulo,
      'artista': artista,
      'album': album,
      'anio': anio,
      'duracion_seg': duracion,
      'favorita': _favorita,
    };

    try {
      if (esEdicion) {
        final int id = widget.cancionExistente!['id'];
        await supabase.from('canciones').update(datos).eq('id', id);
      } else {
        await supabase.from('canciones').insert(datos);
      }

      widget.onGuardar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  esEdicion ? 'Editar Canción' : 'Agregar Canción',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Título
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                if (val.trim().length > 120) {
                  return 'Máximo 120 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Artista
            TextFormField(
              controller: _artistaController,
              decoration: const InputDecoration(
                labelText: 'Artista *',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El artista es obligatorio';
                }
                if (val.trim().length > 120) {
                  return 'Máximo 120 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Álbum
            TextFormField(
              controller: _albumController,
              decoration: const InputDecoration(
                labelText: 'Álbum (Opcional)',
                prefixIcon: Icon(Icons.album_rounded),
              ),
            ),
            const SizedBox(height: 12),

            // Año y Duración en fila
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _anioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Año (1900-2100)',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return null;
                      final n = int.tryParse(val.trim());
                      if (n == null || n < 1900 || n > 2100) {
                        return 'Año inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _duracionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duración (seg)',
                      prefixIcon: Icon(Icons.timer_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return null;
                      final n = int.tryParse(val.trim());
                      if (n == null || n <= 0) {
                        return 'Debe ser > 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Switch Favorita
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Marcar como Favorita'),
              secondary: Icon(
                _favorita ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _favorita ? Colors.redAccent : null,
              ),
              value: _favorita,
              onChanged: (val) => setState(() => _favorita = val),
            ),
            const SizedBox(height: 20),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _cargando ? null : _guardar,
                child: _cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        esEdicion ? 'Guardar Cambios' : 'Agregar Canción',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}