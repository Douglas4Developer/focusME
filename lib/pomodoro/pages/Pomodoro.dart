import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart'; // Importe o pacote de áudio
import 'package:tdah_app/pomodoro/components/Cronometro.dart';
import 'package:tdah_app/pomodoro/components/EntradaTempo.dart';
import 'package:tdah_app/pomodoro/store/pomodoro.store.dart';

class Pomodoro extends StatelessWidget {
  const Pomodoro({Key? key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<PomodoroStore>(context);
    final soundManager = SoundManager();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Implemente a lógica para voltar à tela anterior aqui
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(
            child: Cronometro(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Observer(
              builder: (_) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  EntradaTempo(
                    titulo: 'Trabalho',
                    valor: store.tempoTrabalho,
                    inc: store.iniciado && store.estaTrabalhando()
                        ? null
                        : store.incrementarTempoTrabalho,
                    dec: store.iniciado && store.estaTrabalhando()
                        ? null
                        : store.decrementarTempoTrabalho,
                  ),
                  EntradaTempo(
                    titulo: 'Descanso',
                    valor: store.tempoDescanso,
                    inc: store.iniciado && store.estaDescansando()
                        ? null
                        : store.incrementarTempoDescanso,
                    dec: store.iniciado && store.estaDescansando()
                        ? null
                        : store.decrementarTempoDescanso,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              store.salvarRegistroConcentracao(store.tempoTrabalho);
              // Tocar som para melhorar a concentração
              soundManager.playSound('assets/concentration.mp3');
            },
            child: Text('Salvar Registro de Concentração'),
          ),
        ],
      ),
    );
  }
}

class ConcentracaoRecord {
  final int tempoConcentracao;
  final DateTime dataHora;

  ConcentracaoRecord({required this.tempoConcentracao, required this.dataHora});
}

class SoundManager {
  static final AudioPlayer player = AudioPlayer();

  Future<void> playSound(String soundPath) async {
    await player.play(soundPath as Source);
  }

  Future<void> stopSound() async {
    await player.stop();
  }
}
