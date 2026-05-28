import 'package:flutter/material.dart';

class ProdutoDetalheScreen extends StatefulWidget {
  final String codigoBarras;

  const ProdutoDetalheScreen({
    super.key,
    required this.codigoBarras,
  });

  @override
  State<ProdutoDetalheScreen> createState() => _ProdutoDetalheScreenState();
}

class _ProdutoDetalheScreenState extends State<ProdutoDetalheScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Produto')),
      body: Center(
        child: Text('Produto bipado: ${widget.codigoBarras}'),
      ),
    );
  }
}