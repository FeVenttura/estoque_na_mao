import 'package:hive/hive.dart';

part 'lote.g.dart';

@HiveType(typeId: 1)
class Lote extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String produtoId;
  
  @HiveField(2)
  int quantidade;
  
  @HiveField(3)
  String dataValidade;
  
  @HiveField(4)
  String status;

  Lote({
    required this.id,
    required this.produtoId,
    required this.quantidade,
    required this.dataValidade,
    this.status = 'Fechado',
  });
}