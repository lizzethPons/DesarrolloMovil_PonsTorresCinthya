import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';
import '../services/espn_service.dart';
import '../widgets/match_card.dart';

class TeamSearchScreen extends StatefulWidget {
  final String league;
  const TeamSearchScreen({super.key, required this.league});

  @override
  State<TeamSearchScreen> createState() => _TeamSearchScreenState();
}

class _TeamSearchScreenState extends State<TeamSearchScreen> {
  final _service = EspnService();
  List<TeamModel> _teams = [];
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final t = await _service.getTeams(widget.league);
      if (!mounted) return;
      setState(() {
        _teams = t;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No se pudieron cargar los equipos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _teams
        .where((t) => t.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar equipo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Ej: Barcelona, Arsenal...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!),
                            FilledButton(
                              onPressed: _load,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final t = filtered[i];
                          return ListTile(
                            leading: SizedBox(
                              width: 36,
                              height: 36,
                              child: t.logo != null
                                  ? Image.network(
                                      t.logo!,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.shield),
                                    )
                                  : const Icon(Icons.shield),
                            ),
                            title: Text(t.name),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeamMatchesScreen(
                                  league: widget.league,
                                  team: t,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Partidos y resultados de un equipo
class TeamMatchesScreen extends StatefulWidget {
  final String league;
  final TeamModel team;
  const TeamMatchesScreen({super.key, required this.league, required this.team});

  @override
  State<TeamMatchesScreen> createState() => _TeamMatchesScreenState();
}

class _TeamMatchesScreenState extends State<TeamMatchesScreen> {
  final _service = EspnService();
  late Future<List<MatchModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getTeamSchedule(widget.league, widget.team.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.team.name)),
      body: FutureBuilder<List<MatchModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('No se pudo cargar el calendario'));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Sin partidos disponibles'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => MatchCard(match: list[i]),
          );
        },
      ),
    );
  }
}