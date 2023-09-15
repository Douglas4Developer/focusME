// ignore: file_names
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DashboardProgress extends StatelessWidget {
  const DashboardProgress({super.key});

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
          const Text(
            'Emoção: Feliz',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: 0.75, // Valor do progresso (0 a 1)
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16.0),
          EmotionChart.withSampleData(), // Gráfico de emoções
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
