import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher_string.dart';

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
    const apiKey = 'bfff9459ffc04d1b9714fcb291e48a44';
    const apiUrl = 'https://newsapi.org/v2/everything?q=tdah&apiKey=$apiKey';

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
                      descricao: item['descricao'] ?? '',
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
        backgroundColor: Colors.blue,
        title: const Text('Dicas para TDAH'),
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
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(dica.titulo),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(dica.descricao),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = dica.url;
              if (url != '') {
                await launchUrlString(url);
              } else {
                throw 'Não foi possível abrir a URL: $url';
              }
            },
            child: const Text('Ver notícia completa'),
          ),
        ],
      ),
    );
  }
}
