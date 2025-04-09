import 'package:hive/hive.dart';
import 'match.dart';

part 'round.g.dart';

@HiveType(typeId: 3)
class Round {
  @HiveField(0)
  int number;

  @HiveField(1)
  List<Match> matches;

  Round(this.number, this.matches);
}
