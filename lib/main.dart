import 'package:flutter/material.dart';

void main() {
  runApp(const ReservaViajeApp());
}

class ReservaViajeApp extends StatelessWidget {
  const ReservaViajeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Viaje',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Paleta de colores cambiada: Azul índigo/cobalto como tema primario
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const FormularioReservaScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// PANTALLA 1: Formulario de Reserva
// ---------------------------------------------------------------------------
class FormularioReservaScreen extends StatefulWidget {
  const FormularioReservaScreen({super.key});

  @override
  State<FormularioReservaScreen> createState() => _FormularioReservaScreenState();
}

class _FormularioReservaScreenState extends State<FormularioReservaScreen> {
  // Sección 2: Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  // Sección 3: Destino y Transporte
  String _destinoSeleccionado = 'Playa'; // 'Playa', 'Ciudad', 'Montaña'
  String _transporteSeleccionado = 'Avion';

  // Sección 4: Extras y Preferencias
  bool _hotelIncluido = false;
  bool _tourGuiado = false;
  bool _seguroViaje = false;
  bool _notificaciones = true;
  double _presupuesto = 3000;
  DateTime? _fechaViaje;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  // Método para mostrar SnackBar
  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método para limpiar todos los controles (IconButton de la AppBar)
  void _limpiarFormulario() {
    setState(() {
      _nombreController.clear();
      _correoController.clear();
      _destinoSeleccionado = 'Playa';
      _transporteSeleccionado = 'Avion';
      _hotelIncluido = false;
      _tourGuiado = false;
      _seguroViaje = false;
      _notificaciones = true;
      _presupuesto = 3000;
      _fechaViaje = null;
    });
    _mostrarSnackBar('Formulario limpiado');
  }

  // Selector de fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaViaje ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fechaElegida != null) {
      setState(() {
        _fechaViaje = fechaElegida;
      });
      _mostrarSnackBar(
        'Fecha seleccionada: ${_fechaViaje!.day.toString().padLeft(2, '0')}/${_fechaViaje!.month.toString().padLeft(2, '0')}/${_fechaViaje!.year}',
      );
    }
  }

  // Validador de formulario
  bool _validarFormulario() {
    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();

    return nombre.isNotEmpty &&
        correo.isNotEmpty &&
        correo.contains('@') &&
        _fechaViaje != null;
  }

  // Diálogo de error
  void _mostrarDialogoError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Faltan datos'),
          ],
        ),
        content: const Text(
          'Completa nombre, correo válido (@) y selecciona la fecha del viaje.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // Diálogo Resumen del Viaje
  void _mostrarResumenDialog() {
    if (!_validarFormulario()) {
      _mostrarDialogoError();
      return;
    }

    List<String> extras = [];
    if (_hotelIncluido) extras.add('Hotel');
    if (_tourGuiado) extras.add('Tour');
    if (_seguroViaje) extras.add('Seguro');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assignment_outlined, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Resumen del Viaje'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 Nombre: ${_nombreController.text}'),
            Text('✉️ Correo: ${_correoController.text}'),
            Text('📍 Destino: $_destinoSeleccionado'),
            Text('🚌 Transporte: $_transporteSeleccionado'),
            Text('⭐ Extras: ${extras.isEmpty ? "Ninguno" : extras.join(", ")}'),
            Text('🔔 Notificaciones: ${_notificaciones ? "Activadas" : "Desactivadas"}'),
            Text('💰 Presupuesto: \$${_presupuesto.round()}'),
            Text(
              '📅 Fecha: ${_fechaViaje!.day.toString().padLeft(2, '0')}/${_fechaViaje!.month.toString().padLeft(2, '0')}/${_fechaViaje!.year}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _navegarABoleto();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _navegarABoleto() {
    if (!_validarFormulario()) {
      _mostrarDialogoError();
      return;
    }

    List<String> extras = [];
    if (_hotelIncluido) extras.add('Hotel');
    if (_tourGuiado) extras.add('Tour');
    if (_seguroViaje) extras.add('Seguro');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoletoScreen(
          nombre: _nombreController.text,
          correo: _correoController.text,
          destino: _destinoSeleccionado,
          transporte: _transporteSeleccionado,
          extras: extras.isEmpty ? "Ninguno" : extras.join(", "),
          notificaciones: _notificaciones,
          presupuesto: _presupuesto.round(),
          fecha:
              '${_fechaViaje!.day.toString().padLeft(2, '0')}/${_fechaViaje!.month.toString().padLeft(2, '0')}/${_fechaViaje!.year}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva de Viaje'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Limpiar datos',
            onPressed: _limpiarFormulario,
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // -------------------------------------------------------------
                // Sección 1 - Información general
                // -------------------------------------------------------------
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.indigo.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Sección 1 · Información general',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Completa tu reserva paso a paso',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const Divider(height: 20),
                        const Text(
                          'Llena tus datos, elige destino y confirma tu viaje.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // -------------------------------------------------------------
                // Sección 2 - Datos del viajero
                // -------------------------------------------------------------
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.indigo.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Sección 2 · Datos del viajero',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '¿Quién se va de viaje?',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            hintText: 'Ej: Ana Garcia',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            hintText: 'Ej: ana@correo.com',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // -------------------------------------------------------------
                // Sección 3 - Destino y transporte
                // -------------------------------------------------------------
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.indigo.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Sección 3 · Destino y transporte',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Elige tu aventura',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildDestinoItem('Playa', Icons.beach_access, Colors.blue),
                            _buildDestinoItem('Ciudad', Icons.location_city, Colors.deepOrange),
                            _buildDestinoItem('Montaña', Icons.landscape, Colors.teal),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Transporte:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _transporteSeleccionado,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.directions_bus),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Avion', child: Text('Avión')),
                            DropdownMenuItem(value: 'Autobus', child: Text('Autobús')),
                            DropdownMenuItem(value: 'Tren', child: Text('Tren')),
                            DropdownMenuItem(value: 'Barco', child: Text('Barco')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _transporteSeleccionado = val);
                              _mostrarSnackBar('Transporte: $val');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // -------------------------------------------------------------
                // Sección 4 - Extras y preferencias
                // -------------------------------------------------------------
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune, color: Colors.indigo.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Sección 4 · Extras y preferencias',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Personaliza tu experiencia',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 12),

                        // Extras (Hotel, Tour, Seguro)
                        _buildExtraContainer(
                          title: 'Hotel incluido',
                          subtitle: '+ \$1200',
                          icon: Icons.hotel,
                          value: _hotelIncluido,
                          onChanged: (val) {
                            setState(() => _hotelIncluido = val ?? false);
                            _mostrarSnackBar(
                              'Hotel: ${_hotelIncluido ? "Incluido" : "No incluido"}',
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildExtraContainer(
                          title: 'Tour guiado',
                          subtitle: '+ \$600',
                          icon: Icons.tour,
                          value: _tourGuiado,
                          onChanged: (val) {
                            setState(() => _tourGuiado = val ?? false);
                            _mostrarSnackBar(
                              'Tour: ${_tourGuiado ? "Incluido" : "No incluido"}',
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildExtraContainer(
                          title: 'Seguro de viaje',
                          subtitle: '+ \$400',
                          icon: Icons.health_and_safety,
                          value: _seguroViaje,
                          onChanged: (val) {
                            setState(() => _seguroViaje = val ?? false);
                            _mostrarSnackBar(
                              'Seguro: ${_seguroViaje ? "Incluido" : "No incluido"}',
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Switch Notificaciones
                        Container(
                          decoration: BoxDecoration(
                            color: _notificaciones
                                ? Colors.indigo.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'Recibir notificaciones',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _notificaciones ? 'Activadas' : 'Desactivadas',
                              style: TextStyle(
                                color: _notificaciones
                                    ? Colors.indigo
                                    : Colors.grey,
                              ),
                            ),
                            value: _notificaciones,
                            onChanged: (val) {
                              setState(() => _notificaciones = val);
                              _mostrarSnackBar(
                                'Notificaciones: ${val ? "Activadas" : "Desactivadas"}',
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Presupuesto Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Presupuesto:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              backgroundColor: Colors.indigo,
                              label: Text(
                                '\$${_presupuesto.round()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _presupuesto,
                          min: 500,
                          max: 10000,
                          divisions: 20,
                          activeColor: Colors.indigo,
                          label: '\$${_presupuesto.round()}',
                          onChanged: (val) {
                            setState(() => _presupuesto = val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Selector de fecha
                        InkWell(
                          onTap: () => _seleccionarFecha(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month,
                                    color: Colors.indigo),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fecha del viaje',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        _fechaViaje == null
                                            ? 'Toca para elegir fecha'
                                            : '${_fechaViaje!.day.toString().padLeft(2, '0')}/${_fechaViaje!.month.toString().padLeft(2, '0')}/${_fechaViaje!.year}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // -------------------------------------------------------------
                // Sección 5 - Confirmar
                // -------------------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Sección 5 · Confirmar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Revisa tus datos antes de despegar 🚀',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _mostrarResumenDialog,
                              icon: const Icon(Icons.visibility),
                              label: const Text('Ver Resumen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.indigo.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _navegarABoleto,
                              icon: const Icon(Icons.send),
                              label: const Text('Confirmar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para construir las tarjetas de Destino (Sección 3)
  Widget _buildDestinoItem(String titulo, IconData icon, Color color) {
    final bool seleccionado = _destinoSeleccionado == titulo;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            setState(() => _destinoSeleccionado = titulo);
            _mostrarSnackBar('Destino seleccionado: $titulo');
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: seleccionado ? color.withOpacity(0.15) : Colors.white,
              border: Border.all(
                color: seleccionado ? color : Colors.grey.shade300,
                width: seleccionado ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight:
                        seleccionado ? FontWeight.bold : FontWeight.normal,
                    color: seleccionado ? color : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para construir los contenedores de Extras (Sección 4)
  Widget _buildExtraContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value ? Colors.indigo.shade50 : Colors.white,
        border: Border.all(
          color: value ? Colors.indigo : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        secondary: Icon(icon, color: value ? Colors.indigo : Colors.grey),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PANTALLA 2: Mi Boleto
// ---------------------------------------------------------------------------
class BoletoScreen extends StatelessWidget {
  final String nombre;
  final String correo;
  final String destino;
  final String transporte;
  final String extras;
  final bool notificaciones;
  final int presupuesto;
  final String fecha;

  const BoletoScreen({
    super.key,
    required this.nombre,
    required this.correo,
    required this.destino,
    required this.transporte,
    required this.extras,
    required this.notificaciones,
    required this.presupuesto,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Boleto'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Cabecera del boleto
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade800,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Chip(
                                  backgroundColor: Colors.amber,
                                  label: Text(
                                    fecha,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  _getIconoDestino(destino),
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '¡Buen viaje, $nombre!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                destino.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Detalles del boleto
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _getImagenDestino(destino),
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 100,
                                    color: Colors.indigo.shade100,
                                    child: const Center(
                                      child: Icon(Icons.flight_takeoff,
                                          size: 40, color: Colors.indigo),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: const Icon(Icons.email,
                                    color: Colors.indigo),
                                title: const Text('Correo'),
                                subtitle: Text(correo),
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.indigo),
                                title: const Text('Destino'),
                                subtitle: Text(destino),
                                trailing: Chip(
                                  label: Text(transporte),
                                  avatar: const Icon(Icons.directions_bus,
                                      size: 16),
                                ),
                              ),
                              ListTile(
                                leading:
                                    const Icon(Icons.star, color: Colors.indigo),
                                title: const Text('Extras'),
                                subtitle: Text(extras),
                              ),
                              ListTile(
                                leading: const Icon(Icons.notifications,
                                    color: Colors.indigo),
                                title: const Text('Notificaciones'),
                                subtitle: Text(
                                  notificaciones ? 'Activadas' : 'Desactivadas',
                                ),
                                trailing: Text(
                                  '\$$presupuesto',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Regresar y editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconoDestino(String dest) {
    switch (dest) {
      case 'Ciudad':
        return Icons.location_city;
      case 'Montaña':
        return Icons.landscape;
      default:
        return Icons.beach_access;
    }
  }

  String _getImagenDestino(String dest) {
    switch (dest) {
      case 'Ciudad':
        return 'https://images.unsplash.com/photo-1477959858617-67f30ac4ce71?w=500';
      case 'Montaña':
        return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500';
      default:
        return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500';
    }
  }
}