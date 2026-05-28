import 'package:hive_flutter/hive_flutter.dart';
import '../models/produto.dart';
import '../models/lote.dart';
import '../models/movimentacao.dart';

class StorageService {
  static late Box<Produto> produtoBox;
  static late Box<Lote> loteBox;
  static late Box<Movimentacao> movimentacaoBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(ProdutoAdapter());
    Hive.registerAdapter(LoteAdapter());
    Hive.registerAdapter(MovimentacaoAdapter());

    produtoBox = await Hive.openBox<Produto>('produtos');
    loteBox = await Hive.openBox<Lote>('lotes');
    movimentacaoBox = await Hive.openBox<Movimentacao>('movimentacoes');
  }

  static List<Lote> getLotesPertoDoVencimento() {
    final agora = DateTime.now();
    final limite = agora.add(const Duration(days: 3));

    return loteBox.values.where((lote) {
      if (lote.status == 'Vazio') return false;
      try {
        final data = DateTime.parse(lote.dataValidade);
        return data.isBefore(limite) || data.isAtSameMomentAs(limite);
      } catch (e) {
        return false;
      }
    }).toList();
  }
}