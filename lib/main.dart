import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class Player {
  final int id;
  final String name;

  Player({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Player &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Team {
  final Player player1;
  final Player player2;

  Team(this.player1, this.player2);

  String get displayName => "${player1.name} & ${player2.name}";
}

class Match {
  final Team team1;
  final Team team2;
  final int round;

  Match(this.team1, this.team2, this.round);

  String get displayMatch => "${team1.displayName}\n${team2.displayName}";
}

class Round {
  final int number;
  final List<Match> matches;

  Round(this.number, this.matches);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(int.parse("0xFF009da7")),
      appBar: AppBar(
        title: const Text("Smash League"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
        backgroundColor: Color(int.parse("0xFF009da7")),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            _buildButton("LIGAS", Colors.orange, context, () {}),
            const SizedBox(height: 15),
            _buildButton("SUPER 8", Colors.blue, context, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Super8Screen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, Color color, BuildContext context, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class Super8Screen extends StatefulWidget {
  const Super8Screen({super.key});

  @override
  Super8ScreenState createState() => Super8ScreenState();
}

class Super8ScreenState extends State<Super8Screen> {
  List<Player> players = [];
  final TextEditingController controller = TextEditingController();
  Database? database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    database = await openDatabase(
      p.join(await getDatabasesPath(), 'smash_league.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE players(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)",
        );
      },
      version: 1,
    );
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    if (database == null) return;
    final List<Map<String, dynamic>> maps = await database!.query('players');
    setState(() {
      players = List.generate(maps.length, (i) {
        return Player(
          id: maps[i]['id'] as int,
          name: maps[i]['name'] as String,
        );
      });
    });
  }

  Future<void> _addPlayer() async {
    if (players.length < 8 && controller.text.isNotEmpty && database != null) {
      await database!.insert(
        'players',
        {'name': controller.text},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      controller.clear();
      _loadPlayers();
    }
  }

  Future<void> _removePlayer(int index) async {
    if (database == null) return;
    await database!.delete(
      'players',
      where: "id = ?",
      whereArgs: [players[index].id],
    );
    _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Super 8"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        backgroundColor: const Color(0xFF009da7),
      ),
      body: Container(
        color: const Color(0xFF009da7).withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: "Nome do Jogador",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addPlayer,
                          icon: const Icon(Icons.add, color: Colors.white,),
                          label: const Text("Adicionar Jogador", style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009da7),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: players.isEmpty
                    ? const Center(
                  child: Text(
                    "Nenhum jogador adicionado ainda.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF009da7),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(player.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removePlayer(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (players.length == 8)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        List<Match> partidas = _generateMatches(players);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchesScreen(matches: partidas),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        "Iniciar Jogos",
                        style: TextStyle(color: Colors.white, fontSize: 18),
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

  List<Match> _generateMatches(List<Player> players) {
    if (players.length != 8) {
      throw Exception("Este algoritmo funciona apenas com 8 jogadores.");
    }

    List<Match> matches = [];

    for (int round = 0; round < 7; round++) {
      List<Team> duplas = [];

      for (int i = 0; i < 4; i++) {
        int a = (round + i) % 7;
        int b = (7 - i + round) % 7;

        if (i == 0) b = 7;

        var dupla = Team(players[a], players[b]);
        duplas.add(dupla);
      }

      matches.add(Match(duplas[0], duplas[1], round + 1));
      matches.add(Match(duplas[2], duplas[3], round + 1));
    }

    return matches;
  }



}

class MatchesScreen extends StatefulWidget {
  final List<Match> matches;

  const MatchesScreen({super.key, required this.matches});

  @override
  MatchesScreenState createState() => MatchesScreenState();
}

class MatchesScreenState extends State<MatchesScreen> {
  final Map<String, String> scores = {};
  final Map<Player, int> playerPoints = {};

  void _showScoreDialog(Match match) {
    String matchId = getMatchKey(match);

    TextEditingController team1Controller = TextEditingController(
        text: scores[matchId]?.split('-')[0].trim() ?? '');
    TextEditingController team2Controller = TextEditingController(
        text: scores[matchId]?.split('-')[1].trim() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Registrar Resultado"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rodada ${match.round}\n${match.displayMatch}",
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                maxLength: 1,
                controller: team1Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Pontos de ${getTeamName(match.team1)}",
                  counterText: "",
                ),
              ),
              TextField(
                maxLength: 1,
                controller: team2Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Pontos de ${getTeamName(match.team2)}",
                  counterText: "",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _updatePlayerPoints(
                    match,
                    int.tryParse(team1Controller.text) ?? 0,
                    int.tryParse(team2Controller.text) ?? 0,
                  );

                  scores[matchId] = "${team1Controller.text} - ${team2Controller.text}";
                });
                Navigator.pop(context);
              },
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

  void _updatePlayerPoints(Match match, int newPointsTeam1, int newPointsTeam2) {
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
                        const Icon(Icons.sports_tennis, color: Color(0xFF009da7)),
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
                    _buildMatchTile(match1),
                    const SizedBox(height: 10),
                    _buildMatchTile(match2),
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

  Widget _buildMatchTile(Match match) {
    String matchKey = getMatchKey(match);
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
        onTap: () => _showScoreDialog(match),
      ),
    );
  }

}

class LeaderboardScreen extends StatelessWidget {
  final Map<Player, int> playerPoints;

  const LeaderboardScreen({super.key, required this.playerPoints});

  @override
  Widget build(BuildContext context) {
    // Ordena os jogadores por pontos (do maior pro menor)
    List<MapEntry<Player, int>> sortedPlayers = playerPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
        appBar: AppBar(title: const Text("Classificação Final", style: TextStyle(color: Colors.white),), backgroundColor: Color(int.parse("0xFF009da7")),),
        backgroundColor: Color(int.parse("0xFF009da7")),
        body: ListView.builder(
          itemCount: sortedPlayers.length,
          itemBuilder: (context, index) {
            final player = sortedPlayers[index].key;
            final points = sortedPlayers[index].value;

            // Escolhe ícone e cor com base na posição
            Icon? rankIcon;
            Color? iconColor;

            switch (index) {
              case 0:
                rankIcon = const Icon(Icons.emoji_events, color: Colors.amber, size: 30);
                iconColor = Colors.amber;
                break;
              case 1:
                rankIcon = const Icon(Icons.emoji_events, color: Colors.grey, size: 26);
                iconColor = Colors.grey;
                break;
              case 2:
                rankIcon = const Icon(Icons.emoji_events, color: Colors.brown, size: 24);
                iconColor = Colors.brown;
                break;
            }

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor ?? Colors.blueGrey,
                  child: Text(
                    player.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  "${index + 1}º lugar",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$points pts",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (rankIcon != null) rankIcon,
                  ],
                ),
              ),
            );
          },
        )

    );
  }
}

