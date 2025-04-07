import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:math';

void main() {
  runApp(const MyApp());
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

  Widget _buildButton(String text, Color color, BuildContext context, VoidCallback onPressed) {
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
  List<String> players = [];
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
        return maps[i]['name'] as String;
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
      where: "name = ?",
      whereArgs: [players[index]],
    );
    _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Super 8"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        backgroundColor: Color(int.parse("0xFF009da7")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Nome do Jogador",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPlayer,
              child: const Text("Adicionar Jogador"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("${index+1} - ${players[index]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removePlayer(index),
                    ),
                  );
                },
              ),
            ),
            if (players.length == 8)

              SizedBox(
                width: double.infinity, // Faz o botão ocupar toda a largura disponível
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adiciona padding no eixo X
                  child: ElevatedButton(
                    onPressed: () {
                      List<List<String>> partidas = _generateMatches(players);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MatchesScreen(matches: partidas)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(int.parse("0xFF009da7")),
                    ),
                    child: const Text("Iniciar Jogos", style: TextStyle(color: Colors.white, fontSize: 19)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<List<String>> _generateMatches(List<String> players) {
    if (players.length != 8) throw ArgumentError("É necessário exatamente 8 jogadores.");

    Set<String> usedPairs = {};
    List<List<String>> matches = [];
    Random random = Random();

    while (matches.length < 7) {
      List<String> shuffled = List.from(players)..shuffle(random);
      List<String> round = [];

      String match1Team1 = "${shuffled[0]} & ${shuffled[1]}";
      String match1Team2 = "${shuffled[2]} & ${shuffled[3]}";
      String match2Team1 = "${shuffled[4]} & ${shuffled[5]}";
      String match2Team2 = "${shuffled[6]} & ${shuffled[7]}";

      // Cria as chaves de dupla
      List<String> currentPairs = [
        _pairKey(shuffled[0], shuffled[1]),
        _pairKey(shuffled[2], shuffled[3]),
        _pairKey(shuffled[4], shuffled[5]),
        _pairKey(shuffled[6], shuffled[7]),
      ];

      // Verifica se alguma dessas duplas já foi usada
      bool hasRepeatedPair = currentPairs.any((pair) => usedPairs.contains(pair));

      if (!hasRepeatedPair) {
        usedPairs.addAll(currentPairs);
        round.add("$match1Team1\n$match1Team2");
        round.add("$match2Team1\n$match2Team2");
        matches.add(round);
      }
    }

    return matches;
  }

  String _pairKey(String a, String b) {
    List<String> pair = [a, b]..sort();
    return pair.join("-");
  }

}

class MatchesScreen extends StatefulWidget {
  final List<List<String>> matches;

  const MatchesScreen({super.key, required this.matches});

  @override
  MatchesScreenState createState() => MatchesScreenState();
}

class MatchesScreenState extends State<MatchesScreen> {
  final Map<String, String> scores = {};
  final Map<String, int> playerPoints = {};

  void _showScoreDialog(String match) {
    TextEditingController team1Controller = TextEditingController(text: scores[match]?.split('-')[0] ?? '');
    TextEditingController team2Controller = TextEditingController(text: scores[match]?.split('-')[1] ?? '');

    List<String> teams = match.split("\n");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Registrar Resultado"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(match, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                maxLength: 1,
                controller: team1Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Pontos de ${teams[0]}", counterText: ""),
              ),
              TextField(
                maxLength: 1,
                controller: team2Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Pontos de ${teams[1]}", counterText: ""),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  scores[match] = "${team1Controller.text} - ${team2Controller.text}";
                  _updatePlayerPoints(teams[0], int.parse(team1Controller.text));
                  _updatePlayerPoints(teams[1], int.parse(team2Controller.text));
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

  void _updatePlayerPoints(String team, int points) {
    List<String> players = team.split(" & ");
    for (var player in players) {
      playerPoints[player] = (playerPoints[player] ?? 0) + points;
    }
  }

  bool _allGamesScored() {
    return scores.length == widget.matches.expand((match) => match).length;
  }

  void _finalizeTournament() {
    if (_allGamesScored()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeaderboardScreen(playerPoints: playerPoints)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rodadas"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        backgroundColor: Color(int.parse("0xFF009da7")),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.matches.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rodada ${index + 1}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Column(
                      children: widget.matches[index].map((game) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            tileColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            title: Text(game),
                            subtitle: scores.containsKey(game) ? Text("Resultado: ${scores[game]}") : null,
                            trailing: const Icon(Icons.edit, color: Colors.blue),
                            onTap: () => _showScoreDialog(game),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
          if (_allGamesScored())
            SizedBox(
              width: double.infinity, // Faz o botão ocupar toda a largura disponível
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adiciona padding no eixo X
                child: ElevatedButton(
                  onPressed: _finalizeTournament,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Finalizar", style: TextStyle(color: Colors.white, fontSize: 20),),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  final Map<String, int> playerPoints;

  const LeaderboardScreen({super.key, required this.playerPoints});

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, int>> sortedPlayers = playerPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text("Classificação Final")),
      body: ListView(
        children: sortedPlayers.asMap().entries.map((entry) => ListTile(
          leading: Text("${entry.key + 1}"),
          title: Text(entry.value.key),
          trailing: Text("${entry.value.value} pontos"),
        )).toList(),
      ),
    );
  }
}
