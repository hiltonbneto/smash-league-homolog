import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smash_league/dto/player.dart';
import 'package:smash_league/dto/match.dart';
import 'package:smash_league/dto/round.dart';
import 'package:smash_league/dto/team.dart';
import 'package:smash_league/screens/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const MyApp());
}

late Box<Player> playerBox;

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(TeamAdapter());
  Hive.registerAdapter(MatchAdapter());
  Hive.registerAdapter(RoundAdapter());
  await Hive.openBox<Match>('matches');
  playerBox = await Hive.openBox<Player>('players');
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
