// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchAdapter extends TypeAdapter<Match> {
  @override
  final int typeId = 2;

  @override
  Match read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Match(
      fields[0] as Team,
      fields[1] as Team,
      fields[2] as int,
      scoreTeam1: fields[3] as int?,
      scoreTeam2: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Match obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.team1)
      ..writeByte(1)
      ..write(obj.team2)
      ..writeByte(2)
      ..write(obj.round)
      ..writeByte(3)
      ..write(obj.scoreTeam1)
      ..writeByte(4)
      ..write(obj.scoreTeam2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
