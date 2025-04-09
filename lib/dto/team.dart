import 'package:hive/hive.dart';
import 'player.dart';

part 'team.g.dart';

@HiveType(typeId: 1)
class Team {
  @HiveField(0)
  Player player1;

  @HiveField(1)
  Player player2;

  Team({required this.player1, required this.player2});

  String get displayName => "${player1.name} & ${player2.name}";
}
