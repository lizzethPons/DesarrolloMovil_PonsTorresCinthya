import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';

class EspnService {
  static const _base = 'https://site.api.espn.com/apis/site/v2/sports/soccer';

  /// Ligas disponibles: nombre -> código ESPN
  static const Map<String, String> leagues = {
    'Premier League': 'eng.1',
    'LaLiga': 'esp.1',
    'Bundesliga': 'ger.1',
    'Serie A': 'ita.1',
    'Ligue 1': 'fra.1',
    'Liga MX': 'mex.1',
    'MLS': 'usa.1',
    'Champions League': 'uefa.champions',
    'Europa League': 'uefa.europa',
    'Libertadores': 'conmebol.libertadores',
    'Liga Argentina': 'arg.1',
    'Brasileirão': 'bra.1',
    'Eredivisie': 'ned.1',
    'Liga Portugal': 'por.1',
  };

  Future<Map<String, dynamic>> _get(String url) async {
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Partidos de una liga en una fecha concreta
  Future<List<MatchModel>> getScoreboard(String league, DateTime date) async {
    final d = DateFormat('yyyyMMdd').format(date);
    final data = await _get('$_base/$league/scoreboard?dates=$d');
    final events = (data['events'] as List?) ?? [];
    final list = events
        .map((e) => MatchModel.fromEvent(Map<String, dynamic>.from(e)))
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Todos los equipos de una liga
  Future<List<TeamModel>> getTeams(String league) async {
    final data = await _get('$_base/$league/teams?limit=100');
    final teams = data['sports'][0]['leagues'][0]['teams'] as List;
    final list = teams
        .map((t) => TeamModel.fromJson(Map<String, dynamic>.from(t['team'])))
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// Calendario/resultados de un equipo
  Future<List<MatchModel>> getTeamSchedule(String league, String teamId) async {
    final data = await _get('$_base/$league/teams/$teamId/schedule');
    final events = (data['events'] as List?) ?? [];
    final list = <MatchModel>[];
    for (final e in events) {
      try {
        list.add(MatchModel.fromEvent(Map<String, dynamic>.from(e)));
      } catch (_) {
        // evento con formato raro: se omite
      }
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}