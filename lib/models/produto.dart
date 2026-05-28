import 'package:hive/hive.dart';

part 'produto.g.dart';

@HiveType(typeId: 0)
class Produto extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String nome;
  
  @HiveField(2)
  String codigoBarras;
  
  @HiveField(3)
  int estoqueMinimo;

  Produto({
    required this.id,
    required this.nome,
    required this.codigoBarras,
    this.estoqueMinimo = 5,
  });
}