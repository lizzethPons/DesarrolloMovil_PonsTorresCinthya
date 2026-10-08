import 'package:flutter/material.dart';
import 'package:examen2/controllers/places_controller.dart';
import 'package:examen2/screens/map_screen.dart';
import 'package:examen2/screens/place_form_screen.dart';
import 'package:examen2/screens/places_list_screen.dart';
import 'package:examen2/screens/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _ctrl = PlacesController();
  int _index = 0;
  static const _titles = ['Mi mapa', 'Mis lugares', 'Mi perfil'];

  @override
  void initState() {
    super.initState();
    _ctrl.load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: [
          MapScreen(ctrl: _ctrl),
          PlacesListScreen(ctrl: _ctrl),
          ProfileScreen(ctrl: _ctrl),
        ],
      ),
      floatingActionButton: _index < 2
          ? FloatingActionButton.extended(
              onPressed: () => PlaceFormScreen.open(context, _ctrl),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Agregar'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: 'Mapa'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Lugares'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil'),
        ],
      ),
    );
  }
}