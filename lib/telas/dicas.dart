import 'package:flutter/material.dart';

class DicasScreen extends StatefulWidget {
  @override
  _DicasScreenState createState() => _DicasScreenState();
}

class _DicasScreenState extends State<DicasScreen> {
  List<Dica> _dicas = []; // Lista de dicas

  @override
  void initState() {
    super.initState();
    // Carregar dicas iniciais (pode ser de uma API ou banco de dados)
    _loadDicas();
  }

  void _loadDicas() {
    // Aqui você pode buscar as dicas de uma fonte externa, como uma API
    // Para este exemplo, vou adicionar algumas dicas fictícias
    setState(() {
      _dicas = [
        Dica(
          titulo: 'Dica 1',
          descricao: 'Esta é a descrição da Dica 1.',
        ),
        Dica(
          titulo: 'Dica 2',
          descricao: 'Esta é a descrição da Dica 2.',
        ),
        // Adicione mais dicas conforme necessário
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dicas para TDAH'),
      ),
      body: ListView.builder(
        itemCount: _dicas.length,
        itemBuilder: (context, index) {
          return _buildDicaCard(_dicas[index]);
        },
      ),
    );
  }

  Widget _buildDicaCard(Dica dica) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(dica.titulo),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(dica.descricao),
          ),
        ],
      ),
    );
  }
}

class Dica {
  final String titulo;
  final String descricao;

  Dica({required this.titulo, required this.descricao});
}
