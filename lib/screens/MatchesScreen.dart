import 'package:hive/hive.dart';
import 'package:smash_league/dto/match.dart';
import 'package:flutter/material.dart';
import 'package:smash_league/dto/player.dart';
import 'package:smash_league/dto/team.dart';
import 'package:smash_league/screens/LeaderboardScreen.dart';

class MatchesScreen extends StatefulWidget {
  final List<Match> matches;
  final Box<Match> matchBox;

  const MatchesScreen({
    super.key,
    required this.matches,
    required this.matchBox,
  });

  @override
  MatchesScreenState createState() => MatchesScreenState();
}

class MatchesScreenState extends State<MatchesScreen> {
  final Map<String, String> scores = {};
  final Map<Player, int> playerPoints = {};
  late Box<Match> matchBox;

  @override
  void initState() {
    super.initState();
    _initHive();
    _recalculatePointsFromSavedMatches();
  }

  Future<void> _initHive() async {
    matchBox = Hive.box<Match>('matches');
  }

  void _showScoreDialog(Match match, int index) {
    String matchId = getMatchKey(match);

    for (var matchBox in widget.matchBox.values) {
      if (matchId == getMatchKey(matchBox)) {
        if (matchBox.scoreTeam1 != null && matchBox.scoreTeam2 != null) {
          scores[matchId] = "${matchBox.scoreTeam1} - ${matchBox.scoreTeam2}";
        }
      }
    }

    TextEditingController team1Controller = TextEditingController(
        text: scores[matchId]?.split('-')[0].trim() ?? '');
    TextEditingController team2Controller = TextEditingController(
        text: scores[matchId]?.split('-')[1].trim() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text(
            "Registrar Resultado",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF009DA7),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rodada ${match.round}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                match.displayMatch,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                maxLength: 1,
                controller: team1Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Pontos de ${getTeamName(match.team1)}",
                  labelStyle: const TextStyle(color: Color(0xFF009DA7)),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF009DA7)),
                  ),
                  counterText: "",
                ),
              ),
              TextField(
                maxLength: 1,
                controller: team2Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Pontos de ${getTeamName(match.team2)}",
                  labelStyle: const TextStyle(color: Color(0xFF009DA7)),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF009DA7)),
                  ),
                  counterText: "",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey[600]),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _updatePlayerPoints(
                    match,
                    int.tryParse(team1Controller.text) ?? 0,
                    int.tryParse(team2Controller.text) ?? 0,
                  );

                  scores[matchId] =
                      "${team1Controller.text} - ${team2Controller.text}";

                  match.scoreTeam1 = int.tryParse(team1Controller.text) ?? 0;
                  match.scoreTeam2 = int.tryParse(team2Controller.text) ?? 0;
                });

                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF009DA7),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  String getTeamName(Team team) {
    return "${team.player1.name} & ${team.player2.name}";
  }

  Future<void> _updatePlayerPoints(
      Match match, int newPointsTeam1, int newPointsTeam2) async {
    final matchId = getMatchKey(match);

    // Se já havia um resultado registrado, removemos os pontos antigos
    if (scores.containsKey(matchId)) {
      final parts = scores[matchId]!.split('-');
      final oldPointsTeam1 = int.tryParse(parts[0].trim()) ?? 0;
      final oldPointsTeam2 = int.tryParse(parts[1].trim()) ?? 0;

      for (var player in [match.team1.player1, match.team1.player2]) {
        playerPoints[player] = (playerPoints[player] ?? 0) - oldPointsTeam1;
      }

      for (var player in [match.team2.player1, match.team2.player2]) {
        playerPoints[player] = (playerPoints[player] ?? 0) - oldPointsTeam2;
      }
    }

    // Agora aplicamos os novos pontos
    for (var player in [match.team1.player1, match.team1.player2]) {
      playerPoints[player] = (playerPoints[player] ?? 0) + newPointsTeam1;
    }

    for (var player in [match.team2.player1, match.team2.player2]) {
      playerPoints[player] = (playerPoints[player] ?? 0) + newPointsTeam2;
    }
  }

  bool _allGamesScored() {
    return scores.length == widget.matches.length;
  }

  void _finalizeTournament() {
    if (_allGamesScored()) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LeaderboardScreen(playerPoints: playerPoints)),
      );
    }
  }

  void _recalculatePointsFromSavedMatches() {
    // Limpa os pontos anteriores
    playerPoints.clear();
    if (widget.matchBox.isNotEmpty) {
      for (var match in widget.matchBox.values) {
        // Só processa partidas que já têm placar
        if (match.scoreTeam1 != null && match.scoreTeam2 != null) {
          _updatePlayerPoints(match, match.scoreTeam1!, match.scoreTeam2!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rodadas"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        backgroundColor: Color(int.parse("0xFF009da7")),
      ),
      body: Container(
        color: const Color(0xFF009da7),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: (widget.matches.length / 2).ceil() + 1, // +1 pro botão
          itemBuilder: (context, index) {
            // Último item é o botão
            if (index == (widget.matches.length / 2).ceil()) {
              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _finalizeTournament,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      "Finalizar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              );
            }

            final match1 = widget.matches[index * 2];
            final match2 = widget.matches[index * 2 + 1];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sports_tennis,
                            color: Color(0xFF009da7)),
                        const SizedBox(width: 8),
                        Text(
                          "Rodada ${match1.round}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009da7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMatchTile(match1, index),
                    const SizedBox(height: 10),
                    _buildMatchTile(match2, index),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String getMatchKey(Match match) {
    final allPlayers = [
      match.team1.player1.name,
      match.team1.player2.name,
      match.team2.player1.name,
      match.team2.player2.name
    ]..sort(); // ordena por nome para garantir consistência

    return "Rodada${match.round}_${allPlayers.join('_')}";
  }

  Widget _buildMatchTile(Match match, int index) {
    String matchKey = getMatchKey(match);

    // Itera sobre todas as partidas armazenadas no Hive
    for (int i = 0; i < widget.matchBox.length; i++) {
      final matchBoxItem = widget.matchBox.getAt(i);
      if (matchBoxItem != null &&
          getMatchKey(matchBoxItem) == matchKey &&
          matchBoxItem.scoreTeam1 != null &&
          matchBoxItem.scoreTeam2 != null) {
        scores[matchKey] =
            "${matchBoxItem.scoreTeam1} - ${matchBoxItem.scoreTeam2}";
        break; // encontrou e preencheu, pode parar
      }
    }

    bool hasScore = scores.containsKey(matchKey);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(match.displayMatch),
        subtitle: hasScore ? Text("Resultado: ${scores[matchKey]}") : null,
        trailing: Icon(
          hasScore ? Icons.check_circle : Icons.edit,
          color: hasScore ? Colors.green : Colors.blue,
        ),
        onTap: () => _showScoreDialog(match, index),
      ),
    );
  }
}
