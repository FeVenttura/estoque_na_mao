// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movimentacao.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovimentacaoAdapter extends TypeAdapter<Movimentacao> {
  @override
  final int typeId = 2;

  @override
  Movimentacao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movimentacao(
      id: fields[0] as String,
      loteId: fields[1] as String,
      tipo: fields[2] as String,
      motivo: fields[3] as String,
      data: fields[4] as String,
      quantidade: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Movimentacao obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.loteId)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.motivo)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.quantidade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovimentacaoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
