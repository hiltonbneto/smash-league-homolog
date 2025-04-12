import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smash_league/dto/player.dart';
import 'package:smash_league/dto/match.dart';
import 'package:smash_league/dto/round.dart';
import 'package:smash_league/dto/team.dart';
import 'package:smash_league/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
        primaryColor: const Color(0xFF009da7),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009DA7)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
