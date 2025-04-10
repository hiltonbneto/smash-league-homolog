import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smash_league/dto/player.dart';
import 'package:smash_league/dto/match.dart';
import 'package:smash_league/dto/team.dart';
import 'package:smash_league/screens/MatchesScreen.dart';

class Super8Screen extends StatefulWidget {
  const Super8Screen({super.key});

  @override
  Super8ScreenState createState() => Super8ScreenState();
}

class Super8ScreenState extends State<Super8Screen> {
  List<Player> players = [];
  final TextEditingController controller = TextEditingController();
  late Box<Player> playerBox;
  late Box<Match> matchBox;
  bool hasSavedMatches = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    playerBox = Hive.box<Player>('players');
    matchBox = Hive.box<Match>('matches');
    _loadPlayers();
    setState(() {
      hasSavedMatches = matchBox.isNotEmpty;
    });
  }

  void _loadPlayers() {
    setState(() {
      players = playerBox.values.toList();
    });
  }

  void _resumeMatches() {
    final savedMatches = matchBox.values.toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchesScreen(
          matches: savedMatches,
          matchBox: matchBox,
        ),
      ),
    );
  }

  Future<void> _addPlayer() async {
    final name = controller.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "O nome do jogador não pode estar vazio!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    final exists = players
        .any((player) => player.name.toLowerCase() == name.toLowerCase());

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Esse jogador já está na lista!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    if (players.length < 8) {
      final player = Player(name: name);
      await playerBox.add(player);
      controller.clear();
      _loadPlayers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$name adicionado com sucesso!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1300),
        ),
      );
    }
  }

  Future<void> _removePlayer(int index) async {
    final playerKey = playerBox.keyAt(index);
    await playerBox.delete(playerKey);
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Adicionar Jogador",
                            style: TextStyle(color: Colors.white),
                          ),
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removePlayer(index),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (hasSavedMatches)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _resumeMatches,
                      icon: const Icon(
                        Icons.restore,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Retomar Super 8",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.orange),
                    ),
                  ),
                ),
              if (players.length == 8)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        List<Match> partidas = _generateMatches(players);
                        await matchBox.clear();
                        for (var match in partidas) {
                          await matchBox.add(match);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchesScreen(
                              matches: partidas,
                              matchBox: matchBox,
                            ),
                          ),
                        );
                        setState(() {
                          hasSavedMatches = matchBox.isNotEmpty;
                        });
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
                        "Iniciar Super 8",
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
    List<Player> shuffledPlayers = List.from(players)..shuffle(); // Embaralha os jogadores
    for (int round = 0; round < 7; round++) {
      List<Team> duplas = [];

      for (int i = 0; i < 4; i++) {
        int a = (round + i) % 7;
        int b = (7 - i + round) % 7;

        if (i == 0) b = 7;

        var playerA = shuffledPlayers[a];
        var playerB = (b == 7) ? shuffledPlayers[7] : shuffledPlayers[b]; // Evita erro

        var dupla = Team(player1: playerA, player2: playerB);
        duplas.add(dupla);
      }

      matches.add(Match(duplas[0], duplas[1], round + 1));
      matches.add(Match(duplas[2], duplas[3], round + 1));
    }

    return matches;
  }
}
