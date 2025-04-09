import 'package:flutter/material.dart';
import 'package:smash_league/dto/player.dart';

class LeaderboardScreen extends StatelessWidget {
  final Map<Player, int> playerPoints;

  const LeaderboardScreen({super.key, required this.playerPoints});

  @override
  Widget build(BuildContext context) {
    // Ordena os jogadores por pontos (do maior pro menor)
    List<MapEntry<Player, int>> sortedPlayers = playerPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Classificação Final",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(int.parse("0xFF009da7")),
        ),
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
                rankIcon = const Icon(Icons.emoji_events,
                    color: Colors.amber, size: 24);
                iconColor = Colors.amber;
                break;
              case 1:
                rankIcon = const Icon(Icons.emoji_events,
                    color: Colors.grey, size: 24);
                iconColor = Colors.grey;
                break;
              case 2:
                rankIcon = const Icon(Icons.emoji_events,
                    color: Colors.brown, size: 24);
                iconColor = Colors.brown;
                break;
            }

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
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
        ));
  }
}