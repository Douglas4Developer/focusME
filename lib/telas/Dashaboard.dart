// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DashboardProgress extends StatefulWidget {
  @override
  _DashboardProgressState createState() => _DashboardProgressState();
}

class _DashboardProgressState extends State<DashboardProgress> {
  double _averageHumor = 0.0; // Valor inicial

  @override
  void initState() {
    super.initState();
    _loadHumorData();

    // Configurar um ouvinte de stream para atualizações nos registros de humor
    _setUpHumorStream();
  }

  Future<void> _loadHumorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return; // Sair se o usuário não estiver autenticado
    }

    final uid = user.uid;

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('humores_registrados')
        .where('uid', isEqualTo: uid) // Filtrar por UID do usuário
        .get();

    double totalWeightedHumor = 0.0;
    double totalWeight = 0.0;

    querySnapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final humor = data['humor'];
      final weight = data['peso'] ?? 1.0; // Peso padrão se não houver peso

      // Calcular o humor ponderado com base no peso
      totalWeightedHumor += _getHumorValue(humor) * weight;
      totalWeight += weight;
    });

    if (totalWeight > 0) {
      // Calcular a média do humor ponderado
      _averageHumor = totalWeightedHumor / totalWeight;
    } else {
      _averageHumor = 0.0;
    }

    setState(() {});
  }

  double _getHumorValue(String humor) {
    // Mapear os valores de humor para os respectivos números
    switch (humor) {
      case 'Feliz':
        return 1.0;
      case 'Triste':
        return 0.1;
      case 'Preocupado':
        return 0.5;
      case 'Irritado':
        return 0.2;
      case 'Empolgado':
        return 0.8;
      case 'Ansioso':
        return 0.4;
      default:
        return 0.0;
    }
  }

  void _setUpHumorStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return; // Sair se o usuário não estiver autenticado
    }

    final uid = user.uid;

    // Criar um stream que ouve as alterações nos registros de humor
    FirebaseFirestore.instance
        .collection('humores_registrados')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      // Quando houver uma atualização nos registros, recarregue os dados
      _loadHumorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        children: [
          const Text(
            'Seu Progresso',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Média de Humor: ${(_averageHumor * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: _averageHumor, // Valor da média de humor
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }
}

class FilterOptions extends StatefulWidget {
  const FilterOptions({super.key});

  @override
  _FilterOptionsState createState() => _FilterOptionsState();
}

class _FilterOptionsState extends State<FilterOptions> {
  List<String> filters = ['Semanal', 'Mensal', 'Anual'];
  String selectedFilter = 'Semanal';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: filters.map((filter) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ChoiceChip(
            label: Text(filter),
            selected: selectedFilter == filter,
            onSelected: (selected) {
              setState(() {
                selectedFilter = filter;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}

class EmotionChart extends StatelessWidget {
  final List<charts.Series<EmotionData, String>> seriesList;

  EmotionChart(this.seriesList);

  factory EmotionChart.withSampleData() {
    return EmotionChart(
      _createSampleData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: charts.BarChart(
        seriesList,
        animate: true,
      ),
    );
  }

  static List<charts.Series<EmotionData, String>> _createSampleData() {
    final data = [
      EmotionData('Feliz', 5),
      EmotionData('Triste', 3),
      EmotionData('Ansioso', 2),
      EmotionData('Calmo', 4),
      EmotionData('Irritado', 1),
    ];

    return [
      charts.Series<EmotionData, String>(
        id: 'Emoções',
        domainFn: (EmotionData emo, _) => emo.emotion,
        measureFn: (EmotionData emo, _) => emo.value,
        data: data,
        labelAccessorFn: (EmotionData emo, _) => '${emo.emotion}: ${emo.value}',
        colorFn: (EmotionData emo, _) {
          switch (emo.emotion) {
            case 'Feliz':
              return charts.MaterialPalette.green.shadeDefault;
            case 'Triste':
              return charts.MaterialPalette.blue.shadeDefault;
            case 'Ansioso':
              return charts.MaterialPalette.red.shadeDefault;
            case 'Calmo':
              return charts.MaterialPalette.teal.shadeDefault;
            case 'Irritado':
              return charts.MaterialPalette.deepOrange.shadeDefault;
            default:
              return charts.MaterialPalette.gray.shadeDefault;
          }
        },
      ),
    ];
  }
}

class EmotionData {
  final String emotion;
  final int value;

  EmotionData(this.emotion, this.value);
}
