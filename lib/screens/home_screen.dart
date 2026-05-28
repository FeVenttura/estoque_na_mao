import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final lotesVencendo = StorageService.getLotesPertoDoVencimento();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (lotesVencendo.isNotEmpty)
            Card(
              color: Colors.red.shade100,
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                title: const Text('Atenção: Produtos Vencendo!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                subtitle: Text('${lotesVencendo.length} lotes vencem nos próximos 3 dias.'),
              ),
            ),
          const SizedBox(height: 24),
          const Text('Ações Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScannerScreen()),
                    ).then((_) => setState(() {}));
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, size: 40, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 8),
                        const Text('Bipar Produto', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
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