import 'package:hive/hive.dart';

part 'movimentacao.g.dart';

@HiveType(typeId: 2)
class Movimentacao extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String loteId;
  
  @HiveField(2)
  String tipo;
  
  @HiveField(3)
  String motivo;
  
  @HiveField(4)
  String data;
  
  @HiveField(5)
  int quantidade;

  Movimentacao({
    required this.id,
    required this.loteId,
    required this.tipo,
    required this.motivo,
    required this.data,
    required this.quantidade,
  });
}