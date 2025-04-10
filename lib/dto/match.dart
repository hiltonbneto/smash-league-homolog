import 'package:hive/hive.dart';
import 'team.dart';

part 'match.g.dart';

@HiveType(typeId: 2)
class Match {
  @HiveField(0)
  Team team1;

  @HiveField(1)
  Team team2;

  @HiveField(2)
  int round;

  @HiveField(3)
  int? scoreTeam1;

  @HiveField(4)
  int? scoreTeam2;

  Match(this.team1, this.team2, this.round);

  String get displayMatch => "${team1.displayName}\n${team2.displayName}";
}
