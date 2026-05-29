import 'package:hive/hive.dart';

part 'lote.g.dart';

@HiveType(typeId: 1)
class Lote extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String codigoBarras; // Mudamos aqui! Agora o lote se vincula ao código de barras direto.
  
  @HiveField(2)
  int quantidade;
  
  @HiveField(3)
  String dataValidade;
  
  @HiveField(4)
  String status;

  Lote({
    required this.id,
    required this.codigoBarras,
    required this.quantidade,
    required this.dataValidade,
    this.status = 'Fechado',
  });
}