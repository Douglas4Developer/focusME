import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dica {
  final String titulo;
  final String descricao;
  final String url; // URL da notícia completa

  Dica({required this.titulo, required this.descricao, required this.url});
}

class DicasScreen extends StatefulWidget {
  @override
  _DicasScreenState createState() => _DicasScreenState();
}

class _DicasScreenState extends State<DicasScreen> {
  List<Dica> _dicas = [];

  @override
  void initState() {
    super.initState();
    _loadDicas();
  }

  Future<void> _loadDicas() async {
    final apiKey = 'bfff9459ffc04d1b9714fcb291e48a44';
    final apiUrl = 'https://newsapi.org/v2/everything?q=tdah&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('articles')) {
          final List<dynamic> articles = data['articles'];
          setState(() {
            _dicas = articles
                .map((item) => Dica(
                      titulo: item['title'] ?? '',
                      descricao: item['description'] ?? '',
                      url: item['url'] ?? '', // URL da notícia completa
                    ))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar notícias: $e');
    }
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
          ElevatedButton(
            onPressed: () {
              // Navegar para a notícia completa usando WebView
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DicaWebView(url: dica.url),
                ),
              );
            },
            child: Text('Ver notícia completa'),
          ),
        ],
      ),
    );
  }
}

class DicaWebView extends StatelessWidget {
  final String url;

  DicaWebView({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notícia Completa'),
      ),
      body: DicaWebView(
        url: url,
      ),
    );
  }
}
