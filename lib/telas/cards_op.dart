import 'package:flutter/material.dart';
import 'package:tdah_app/pomodoro/pages/Pomodoro.dart';

import 'package:tdah_app/telas/dicas.dart';
import 'package:tdah_app/telas/humor.dart';
import 'package:tdah_app/telas/lembretes.dart';
import 'package:tdah_app/telas/medicamentos.dart';
import 'package:tdah_app/telas/sintomas.dart';
import 'package:tdah_app/telas/tasks.dart';

class OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;

  const OptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    void navigateToPage(BuildContext context, Widget page) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    }

    return GestureDetector(
      onTap: () {
        navigateToPage(context, page);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.0,
              color: Colors.blue,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<OptionCard> options = [
  const OptionCard(
    icon: Icons.book,
    title: 'Concentração',
    page: Pomodoro(),
  ),
  OptionCard(
    icon: Icons.mood,
    title: 'Humor',
    page: CadastroHumorScreen(),
  ),
  OptionCard(
    icon: Icons.table_rows,
    title: 'Sintomas',
    page: SintomaScreen(),
  ),
  OptionCard(
    icon: Icons.health_and_safety,
    title: 'Medicamentos',
    page: MedicacaoScreen(),
  ),

  OptionCard(
    icon: Icons.assignment,
    title: 'Tarefas',
    page: TaskScreen(),
  ),
  OptionCard(
    icon: Icons.alarm,
    title: 'Lembretes',
    page: CadastroLembreteScreen(),
  ),

  OptionCard(
    icon: Icons.alarm,
    title: 'Saiba Mais',
    page: DicasScreen(),
  ),

  // Mais opções podem ser adicionadas aqui
];
