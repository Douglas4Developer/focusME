import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:tdah_app/pomodoro/components/CronometroBotao.dart';
import '../store/pomodoro.store.dart';

class Cronometro extends StatefulWidget {
  const Cronometro({Key? key}) : super(key: key);

  @override
  _CronometroState createState() => _CronometroState();
}

class _CronometroState extends State<Cronometro> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Inicia o timer que atualiza a cada 100 milissegundos
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      // Redesenha o widget a cada atualização para atualizar o progresso
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // Cancela o timer quando o widget for descartado
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<PomodoroStore>(context);

    final milissegundosRestantes = (store.minutos * 60 + store.segundos) * 1000;
    final milissegundosTotais =
        (store.tempoTrabalho * 60 + store.tempoDescanso) * 1000;

    final progresso = milissegundosRestantes / milissegundosTotais;

    return Observer(
      builder: (_) {
        return Container(
          color: store.estaTrabalhando() ? Colors.red : Colors.green,
          padding:
              const EdgeInsets.all(16.0), // Espaçamento ao redor do conteúdo
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                store.estaTrabalhando()
                    ? 'Hora de Concentrar'
                    : 'Hora de Descansar',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progresso,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue, // Cor do progresso
                      ),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      strokeWidth: 12.0,
                    ),
                  ),
                  Text(
                    '${store.minutos.toString().padLeft(2, '0')}:${store.segundos.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!store.iniciado)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CronometroBotao(
                        texto: 'Iniciar',
                        icone: Icons.play_arrow,
                        click: store.iniciar,
                      ),
                    ),
                  if (store.iniciado)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CronometroBotao(
                        texto: 'Parar',
                        icone: Icons.stop,
                        click: store.parar,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: CronometroBotao(
                      texto: 'Reiniciar',
                      icone: Icons.refresh,
                      click: store.reiniciar,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
