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

  // Validação rígida do código de barras brasileiro (Apenas números, entre 8 e 14 dígitos - cobrindo EAN-13, EAN-8 e DUN-14)
  static bool codigoBarrasEValido(String codigo) {
    final codigoLimpo = codigo.trim();
    
    // Expressão regular: Garante que CONTÉM APENAS NÚMEROS e tem tamanho de 8 a 14 caracteres
    final regExp = RegExp(r'^\d{8,14}$');
    
    return regExp.hasMatch(codigoLimpo);
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

  static Produto? getProdutoPorCodigo(String codigoBarras) {
    try {
      final codigoLimpo = codigoBarras.trim();
      return produtoBox.values.firstWhere((p) => p.codigoBarras == codigoLimpo);
    } catch (e) {
      return null;
    }
  }
}