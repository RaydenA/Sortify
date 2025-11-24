// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basket.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BasketAdapter extends TypeAdapter<Basket> {
  @override
  final int typeId = 0;

  @override
  Basket read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Basket()
      ..name = fields[0] as String
      ..redAvgsA = (fields[1] as List).cast<int>()
      ..greenAvgsA = (fields[2] as List).cast<int>()
      ..blueAvgsA = (fields[3] as List).cast<int>()
      ..redAvgsB = (fields[4] as List).cast<int>()
      ..greenAvgsB = (fields[5] as List).cast<int>()
      ..blueAvgsB = (fields[6] as List).cast<int>();
  }

  @override
  void write(BinaryWriter writer, Basket obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.redAvgsA)
      ..writeByte(2)
      ..write(obj.greenAvgsA)
      ..writeByte(3)
      ..write(obj.blueAvgsA)
      ..writeByte(4)
      ..write(obj.redAvgsB)
      ..writeByte(5)
      ..write(obj.greenAvgsB)
      ..writeByte(6)
      ..write(obj.blueAvgsB);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
