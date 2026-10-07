import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final m = match;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _statusBadge(context),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _team(m.homeName, m.homeLogo)),
                _center(context),
                Expanded(child: _team(m.awayName, m.awayLogo)),
              ],
            ),
            if (m.venue != null) ...[
              const SizedBox(height: 10),
              Text(
                m.venue!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context) {
    if (match.isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'EN VIVO · ${match.statusText}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Text(
      match.isFinished
          ? 'Finalizado · ${DateFormat('d MMM', 'es').format(match.date)}'
          : DateFormat('EEE d MMM', 'es').format(match.date),
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  Widget _center(BuildContext context) {
    if (match.isUpcoming) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          DateFormat('HH:mm').format(match.date),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '${match.homeScore} - ${match.awayScore}',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: match.isLive ? Colors.redAccent : null,
        ),
      ),
    );
  }

  Widget _team(String name, String? logo) {
    return Column(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: logo != null
              ? Image.network(
                  logo,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shield, size: 40, color: Colors.grey),
                )
              : const Icon(Icons.shield, size: 40, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}