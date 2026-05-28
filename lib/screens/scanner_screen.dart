import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'produto_detalhe_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler Código de Barras'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: MobileScanner(
        onDetect: (capture) {
          if (_isNavigating) return;

          final List<Barcode> barcodes = capture.barcodes;
          
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() => _isNavigating = true);
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProdutoDetalheScreen(
                    codigoBarras: barcode.rawValue!,
                  ),
                ),
              );
              break;
            }
          }
        },
      ),
    );
  }
}