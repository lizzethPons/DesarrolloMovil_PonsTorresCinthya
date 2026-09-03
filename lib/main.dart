import 'package:flutter/material.dart';

void main() {
  runApp(const RegistroPreferenciasApp());
}

/// Widget principal de la aplicación. Configura el tema global y la pantalla inicial.
class RegistroPreferenciasApp extends StatelessWidget {
  const RegistroPreferenciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Preferencias',
      debugShowCheckedModeBanner: true, // Muestra la etiqueta 'DEBUG' en la esquina
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const PreferencesScreen(),
    );
  }
}

/// Pantalla con estado (StatefulWidget) para mantener el control de los campos, checkboxes y radio buttons.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Controladores para capturar el texto ingresado en los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Estado para la sección de Género (Radio Buttons)
  String _selectedGender = 'Masculino';

  // Estado para la sección de Intereses (Checkboxes)
  bool _sport = false;
  bool _music = false;
  bool _cinema = false;
  bool _reading = false;

  // Estado para la sección de País (Dropdown)
  String? _selectedCountry = 'MX';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// Muestra un mensaje flotante (SnackBar) al interactuar con los botones.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4FA), // Fondo ligeramente rosado como el diseño
      appBar: AppBar(
        title: const Text('Registro de Preferencias'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          // BoxConstraints limita el ancho máximo a 800px para evitar distorsiones en vista Web
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // SECCIÓN 1: Información General
                _buildSectionCard(
                  backgroundColor: const Color(0xFFE8F1F9),
                  borderColor: const Color(0xFFC7E0F4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderTitle(
                        icon: Icons.info_outline,
                        title: 'Seccion 1: Informacion General',
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completa los siguientes datos personales basicos',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // SECCIÓN 2: Datos Personales
                _buildSectionCard(
                  backgroundColor: const Color(0xFFEDF7ED),
                  borderColor: const Color(0xFFC8E6C9),
                  child: Column(
                    children: [
                      _buildHeaderTitle(
                        icon: Icons.person_outline,
                        title: 'Seccion 2: Datos Personales',
                        color: Colors.green.shade800,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Edad',
                          prefixIcon: Icon(Icons.calendar_today),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // SECCIÓN 3: Distribución en Filas
                _buildSectionCard(
                  backgroundColor: const Color(0xFFFFF7E6),
                  borderColor: const Color(0xFFFFE5B4),
                  child: Column(
                    children: [
                      _buildHeaderTitle(
                        icon: Icons.view_headline,
                        title: 'Seccion 3: Distribucion en Filas',
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(height: 12),
                      _buildColorRow(
                        color: Colors.red.shade100,
                        dotColor: Colors.red,
                        text: 'Fila 1 - Color Rojo',
                      ),
                      const SizedBox(height: 8),
                      _buildColorRow(
                        color: Colors.yellow.shade100,
                        dotColor: Colors.yellow.shade700,
                        text: 'Fila 2 - Color Amarillo',
                      ),
                      const SizedBox(height: 8),
                      _buildColorRow(
                        color: Colors.blue.shade100,
                        dotColor: Colors.blue,
                        text: 'Fila 3 - Color Azul',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // SECCIÓN 4: Cuatro Hijos en Colores
                _buildSectionCard(
                  backgroundColor: const Color(0xFFF3E5F5),
                  borderColor: const Color(0xFFE1BEE7),
                  child: Column(
                    children: [
                      _buildHeaderTitle(
                        icon: Icons.grid_view,
                        title: 'Seccion 4: Cuatro Hijos en Colores',
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildColorChild(
                            label: 'Hijo 1',
                            bgColor: Colors.pink.shade100,
                            textColor: Colors.pink.shade800,
                          ),
                          _buildColorChild(
                            label: 'Hijo 2',
                            bgColor: Colors.amber.shade100,
                            textColor: Colors.amber.shade900,
                          ),
                          _buildColorChild(
                            label: 'Hijo 3',
                            bgColor: Colors.green.shade100,
                            textColor: Colors.green.shade800,
                          ),
                          _buildColorChild(
                            label: 'Hijo 4',
                            bgColor: Colors.purple.shade100,
                            textColor: Colors.purple.shade800,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // SECCIÓN 5: Controles UI
                _buildSectionCard(
                  backgroundColor: const Color(0xFFF5F5F5),
                  borderColor: const Color(0xFFE0E0E0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderTitle(
                        icon: Icons.add_circle_outline,
                        title: 'Seccion 5: Controles UI',
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(height: 12),

                      // Radio Buttons para Género
                      const Text(
                        'Genero:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildRadioOption('Masculino'),
                      _buildRadioOption('Femenino'),
                      _buildRadioOption('Otro'),

                      const SizedBox(height: 12),

                      // Checkboxes para Intereses
                      const Text(
                        'Intereses:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildCheckboxOption('Deporte', _sport, (val) {
                        setState(() => _sport = val ?? false);
                      }),
                      _buildCheckboxOption('Musica', _music, (val) {
                        setState(() => _music = val ?? false);
                      }),
                      _buildCheckboxOption('Cine', _cinema, (val) {
                        setState(() => _cinema = val ?? false);
                      }),
                      _buildCheckboxOption('Lectura', _reading, (val) {
                        setState(() => _reading = val ?? false);
                      }),

                      const SizedBox(height: 12),

                      // Dropdown para País
                      const Text(
                        'Pais:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.public),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'MX', child: Text('Mexico')),
                          DropdownMenuItem(value: 'US', child: Text('Estados Unidos')),
                          DropdownMenuItem(value: 'ES', child: Text('Espana')),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedCountry = val);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Botones inferiores
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showSnackBar(
                                  'Nombre: ${_nameController.text}, Género: $_selectedGender, País: $_selectedCountry',
                                );
                              },
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Mostrar Preferencias'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showSnackBar('Registro guardado correctamente');
                              },
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('Guardar Registro'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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

  // --- MÉTODOS Y WIDGETS AUXILIARES PARA REUTILIZAR CÓDIGO ---

  /// Crea la tarjeta contenedora base para cada una de las 5 secciones
  Widget _buildSectionCard({
    required Widget child,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: child,
    );
  }

  /// Construye el título con ícono de cada sección
  Widget _buildHeaderTitle({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Construye las filas de colores utilizadas en la Sección 3
  Widget _buildColorRow({
    required Color color,
    required Color dotColor,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 16, color: dotColor),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// Construye los bloques pequeños flexibles de la Sección 4
  Widget _buildColorChild({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Helper para simplificar las opciones de Radio Buttons (Sección 5)
  Widget _buildRadioOption(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedGender,
          onChanged: (val) {
            setState(() => _selectedGender = val!);
          },
        ),
        Text(value),
      ],
    );
  }

  /// Helper para simplificar las opciones de Checkbox (Sección 5)
  Widget _buildCheckboxOption(
    String label,
    bool currentValue,
    Function(bool?) onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: currentValue,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }
}