import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/produto.dart';
import '../models/lote.dart';
import '../models/movimentacao.dart';

class ProdutoDetalheScreen extends StatefulWidget {
  final String codigoBarras;
  const ProdutoDetalheScreen({super.key, required this.codigoBarras});

  @override
  State<ProdutoDetalheScreen> createState() => _ProdutoDetalheScreenState();
}

class _ProdutoDetalheScreenState extends State<ProdutoDetalheScreen> {
  Produto? produtoAtual;
  List<Lote> lotesAtivos = [];
  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    final codigoLimpo = widget.codigoBarras.trim();
    setState(() {
      produtoAtual = StorageService.getProdutoPorCodigo(codigoLimpo);
      if (produtoAtual != null) {
        lotesAtivos = StorageService.loteBox.values.where((l) => l.codigoBarras == codigoLimpo && l.status != 'Vazio').toList();
        lotesAtivos.sort((a, b) => a.dataValidade.compareTo(b.dataValidade));
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvarNovoProduto() async {
    if (_nomeController.text.isEmpty) return;
    final novoProduto = Produto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nomeController.text.trim(),
      codigoBarras: widget.codigoBarras.trim(),
    );
    await StorageService.produtoBox.put(novoProduto.id, novoProduto);
    _carregarDados();
  }

  void _mostrarDialogoEntrada() {
    final qtdController = TextEditingController();
    final validadeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Novo Lote', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtdController,
              decoration: InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.add_box_outlined)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: validadeController,
              decoration: InputDecoration(labelText: 'Validade (AAAA-MM-DD)', hintText: 'Ex: 2026-12-30', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.calendar_month)),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (qtdController.text.isEmpty || validadeController.text.isEmpty) return;
              final qtd = int.tryParse(qtdController.text.trim());
              if (qtd == null || qtd <= 0) return;

              final idLote = DateTime.now().millisecondsSinceEpoch.toString();
              final novoLote = Lote(id: idLote, codigoBarras: widget.codigoBarras.trim(), quantidade: qtd, dataValidade: validadeController.text.trim(), status: 'Fechado');
              await StorageService.loteBox.put(novoLote.id, novoLote);
              
              final idMov = DateTime.now().add(const Duration(milliseconds: 1)).millisecondsSinceEpoch.toString();
              final mov = Movimentacao(id: idMov, loteId: novoLote.id, tipo: 'Entrada', motivo: 'Compra', data: DateTime.now().toIso8601String(), quantidade: novoLote.quantidade);
              await StorageService.movimentacaoBox.put(mov.id, mov);

              if (context.mounted) Navigator.pop(context);
              _carregarDados();
            },
            child: const Text('Confirmar Entrada'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoBaixa() {
    if (lotesAtivos.isEmpty) return;
    final qtdController = TextEditingController();
    String motivoSelecionado = 'Uso/Venda';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Dar Baixa', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtdController,
                  decoration: InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: motivoSelecionado,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: const [
                    DropdownMenuItem(value: 'Uso/Venda', child: Text('Uso Normal')),
                    DropdownMenuItem(value: 'Vencido', child: Text('Desperdício: Vencido')),
                    DropdownMenuItem(value: 'Quebrado', child: Text('Desperdício: Quebrado')),
                  ],
                  onChanged: (value) => setStateDialog(() => motivoSelecionado = value!),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (qtdController.text.isNotEmpty) {
                    int qtdBaixa = int.parse(qtdController.text.trim());
                    final loteMaisAntigo = lotesAtivos.first;
                    if (qtdBaixa > loteMaisAntigo.quantidade) return;

                    loteMaisAntigo.quantidade -= qtdBaixa;
                    loteMaisAntigo.status = loteMaisAntigo.quantidade == 0 ? 'Vazio' : 'Em Uso';
                    await loteMaisAntigo.save();

                    final mov = Movimentacao(id: DateTime.now().millisecondsSinceEpoch.toString(), loteId: loteMaisAntigo.id, tipo: motivoSelecionado == 'Uso/Venda' ? 'Saida' : 'Desperdicio', motivo: motivoSelecionado, data: DateTime.now().toIso8601String(), quantidade: qtdBaixa);
                    await StorageService.movimentacaoBox.put(mov.id, mov);

                    if (context.mounted) Navigator.pop(context);
                    _carregarDados();
                  }
                },
                child: const Text('Confirmar Saída'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produto')),
      body: Column(
        children: [
          // Header Elegante do Produto
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
                  child: Icon(Icons.inventory_2_rounded, size: 40, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(produtoAtual?.nome ?? 'Novo Produto', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                        child: Text('CÓDIGO: ${widget.codigoBarras}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, letterSpacing: 1.5, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: produtoAtual == null
                  // Tela de Cadastro
                  ? Center(
                      child: SingleChildScrollView(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(Icons.add_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 16),
                                const Text('Produto não encontrado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Cadastre o nome deste produto para começar.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                                const SizedBox(height: 24),
                                TextField(
                                  controller: _nomeController,
                                  decoration: InputDecoration(labelText: 'Nome (Ex: Arroz 5kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: FilledButton(onPressed: _salvarNovoProduto, style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Salvar Produto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  // Lista de Lotes
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estoque Atual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (lotesAtivos.isEmpty)
                          Expanded(child: Center(child: Text('Nenhum lote registrado.\nClique em + Entrada.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 16))))
                        else
                          Expanded(
                            child: ListView.separated(
                              itemCount: lotesAtivos.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final lote = lotesAtivos[index];
                                final isUso = index == 0;
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: isUso ? BorderSide(color: Colors.orange.shade300, width: 2) : BorderSide.none,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: isUso ? Colors.orange.shade100 : Colors.grey.shade100,
                                      child: Text('${lote.quantidade}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isUso ? Colors.orange.shade900 : Colors.black87)),
                                    ),
                                    title: Text('Validade: ${lote.dataValidade}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text('ID: ${lote.id.substring(lote.id.length - 4)}', style: TextStyle(color: Colors.grey.shade500)),
                                    trailing: isUso 
                                      ? Chip(label: const Text('EM USO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.orange.shade400, side: BorderSide.none)
                                      : Chip(label: const Text('FECHADO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Colors.grey.shade200, side: BorderSide.none),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      // Rodapé de Ações
      bottomNavigationBar: produtoAtual == null ? null : SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _mostrarDialogoEntrada,
                  icon: const Icon(Icons.add),
                  label: const Text('Entrada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _mostrarDialogoBaixa,
                  icon: const Icon(Icons.remove),
                  label: const Text('Baixa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}