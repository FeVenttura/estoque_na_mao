// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lote.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoteAdapter extends TypeAdapter<Lote> {
  @override
  final int typeId = 1;

  @override
  Lote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lote(
      id: fields[0] as String,
      codigoBarras: fields[1] as String,
      quantidade: fields[2] as int,
      dataValidade: fields[3] as String,
      status: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Lote obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.codigoBarras)
      ..writeByte(2)
      ..write(obj.quantidade)
      ..writeByte(3)
      ..write(obj.dataValidade)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
