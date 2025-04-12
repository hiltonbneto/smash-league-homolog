import '../dto/match.dart';

String getMatchKey(Match match) {
  final allPlayerIds = [
    match.team1.player1.id,
    match.team1.player2.id,
    match.team2.player1.id,
    match.team2.player2.id
  ]..sort(); // ordena por ID para garantir consistência

  return "Rodada${match.round}_${allPlayerIds.join('_')}";
}
