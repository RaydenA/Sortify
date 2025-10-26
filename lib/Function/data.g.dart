// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ColorSetAdapter extends TypeAdapter<ColorSet> {
  @override
  final int typeId = 0;

  @override
  ColorSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ColorSet()
      ..name = fields[0] as String
      ..redAvgs = (fields[1] as List).cast<int>()
      ..greenAvgs = (fields[2] as List).cast<int>()
      ..blueAvgs = (fields[3] as List).cast<int>();
  }

  @override
  void write(BinaryWriter writer, ColorSet obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.redAvgs)
      ..writeByte(2)
      ..write(obj.greenAvgs)
      ..writeByte(3)
      ..write(obj.blueAvgs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
