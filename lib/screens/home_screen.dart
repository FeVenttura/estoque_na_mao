import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'scanner_screen.dart';
import 'produto_detalhe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _mostrarDialogoDigitacao() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Buscar Produto', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Código de barras',
            hintText: 'Ex: 7891234567890',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.qr_code),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              final codigoDigitado = controller.text.trim();
              if (!StorageService.codigoBarrasEValido(codigoDigitado)) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: const Text('Código inválido! Use apenas números.'),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProdutoDetalheScreen(codigoBarras: codigoDigitado)),
              ).then((_) => setState(() {}));
            },
            child: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotesVencendo = StorageService.getLotesPertoDoVencimento();

    return Scaffold(
      appBar: AppBar(title: const Text('Visão Geral')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const Text('Bem-vindo ao Estoque!', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),

          // Card de Alerta com Gradiente Premium
          if (lotesVencendo.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.orange.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.warning_rounded, color: Colors.white, size: 32),
                ),
                title: const Text('Atenção: Vencimentos!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                subtitle: Text('${lotesVencendo.length} lotes vencem nos próximos 3 dias.', style: const TextStyle(color: Colors.white70)),
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          const Text('Ações Rápidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Botões Principais Estilizados
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())).then((_) => setState(() {}));
                  },
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 12),
                          Text('Ler Câmera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _mostrarDialogoDigitacao,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.keyboard_alt_outlined, size: 48, color: Colors.grey.shade700),
                          const SizedBox(height: 12),
                          Text('Digitar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}