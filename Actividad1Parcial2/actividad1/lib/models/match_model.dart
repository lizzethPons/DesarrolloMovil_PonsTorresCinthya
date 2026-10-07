class MatchModel {
  final String id;
  final DateTime date;
  final String homeName;
  final String awayName;
  final String? homeLogo;
  final String? awayLogo;
  final String homeScore;
  final String awayScore;
  final String state; // pre = próximo, in = en vivo, post = finalizado
  final String statusText;
  final String? venue;

  MatchModel({
    required this.id,
    required this.date,
    required this.homeName,
    required this.awayName,
    this.homeLogo,
    this.awayLogo,
    required this.homeScore,
    required this.awayScore,
    required this.state,
    required this.statusText,
    this.venue,
  });

  bool get isLive => state == 'in';
  bool get isFinished => state == 'post';
  bool get isUpcoming => state == 'pre';

  static String _score(dynamic s) {
    if (s == null) return '-';
    if (s is Map) return (s['displayValue'] ?? '-').toString();
    return s.toString();
  }

  static String? _logo(Map<String, dynamic> team) {
    if (team['logo'] != null) return team['logo'].toString();
    final logos = team['logos'];
    if (logos is List && logos.isNotEmpty) {
      return logos.first['href']?.toString();
    }
    return null;
  }

  factory MatchModel.fromEvent(Map<String, dynamic> e) {
    final comp = (e['competitions'] as List).first as Map<String, dynamic>;
    final competitors = comp['competitors'] as List;
    final home = competitors.firstWhere((c) => c['homeAway'] == 'home');
    final away = competitors.firstWhere((c) => c['homeAway'] == 'away');

    final status = (comp['status'] ?? e['status']) as Map<String, dynamic>?;
    final type = status?['type'] as Map<String, dynamic>?;
    final state = (type?['state'] ?? 'pre').toString();

    String statusText = (type?['shortDetail'] ?? type?['detail'] ?? '').toString();
    if (state == 'in') {
      final clock = status?['displayClock'];
      if (clock != null) statusText = clock.toString();
    } else if (state == 'post') {
      statusText = 'Finalizado';
    }

    final dateStr = (e['date'] ?? comp['date']).toString();

    return MatchModel(
      id: e['id'].toString(),
      date: DateTime.parse(dateStr).toLocal(),
      homeName: home['team']['displayName'].toString(),
      awayName: away['team']['displayName'].toString(),
      homeLogo: _logo(Map<String, dynamic>.from(home['team'])),
      awayLogo: _logo(Map<String, dynamic>.from(away['team'])),
      homeScore: state == 'pre' ? '-' : _score(home['score']),
      awayScore: state == 'pre' ? '-' : _score(away['score']),
      state: state,
      statusText: statusText,
      venue: comp['venue']?['fullName']?.toString(),
    );
  }
}