import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  String name;

  Player({required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Player && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}
