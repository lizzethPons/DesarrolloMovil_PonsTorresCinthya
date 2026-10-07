import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match_model.dart';
import '../services/espn_service.dart';
import '../widgets/match_card.dart';
import 'team_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = EspnService();
  String _league = 'eng.1';
  DateTime _date = DateTime.now();
  int _filter = 0; // 0 todos, 1 en vivo, 2 finalizados, 3 próximos
  List<MatchModel> _matches = [];
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    // Actualización automática cada 30 s si estamos viendo "hoy"
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isToday) _load(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isToday {
    final n = DateTime.now();
    return _date.year == n.year && _date.month == n.month && _date.day == n.day;
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _service.getScoreboard(_league, _date);
      if (!mounted) return;
      setState(() {
        _matches = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() {
          _loading = false;
          _error = 'No se pudo cargar. Revisa tu conexión.';
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _load();
    }
  }

  void _changeDay(int days) {
    setState(() => _date = _date.add(Duration(days: days)));
    _load();
  }

  List<MatchModel> get _filtered {
    switch (_filter) {
      case 1:
        return _matches.where((m) => m.isLive).toList();
      case 2:
        return _matches.where((m) => m.isFinished).toList();
      case 3:
        return _matches.where((m) => m.isUpcoming).toList();
      default:
        return _matches;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveCount = _matches.where((m) => m.isLive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ESPN Scores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar equipo',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeamSearchScreen(league: _league),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _load(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de liga
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: DropdownButtonFormField<String>(
              value: _league,
              decoration: const InputDecoration(
                labelText: 'Liga',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: EspnService.leagues.entries
                  .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _league = v);
                _load();
              },
            ),
          ),
          // Selector de fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDay(-1),
              ),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _isToday
                      ? 'Hoy · ${DateFormat('d MMM', 'es').format(_date)}'
                      : DateFormat('EEE d MMM yyyy', 'es').format(_date),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeDay(1),
              ),
            ],
          ),
          // Filtros de estado
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('Todos', 0),
                _chip(liveCount > 0 ? 'En vivo ($liveCount)' : 'En vivo', 1),
                _chip('Finalizados', 2),
                _chip('Próximos', 3),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _chip(String label, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == index,
        onSelected: (_) => setState(() => _filter = index),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            FilledButton(onPressed: () => _load(), child: const Text('Reintentar')),
          ],
        ),
      );
    }
    final list = _filtered;
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: list.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No hay partidos para este filtro')),
              ],
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => MatchCard(match: list[i]),
            ),
    );
  }
}