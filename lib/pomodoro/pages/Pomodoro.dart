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

    final isMobile = MediaQuery.of(context).size.width <
        600; // Exemplo de verificação de tamanho de tela

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pop(); // Adicione essa linha para voltar à tela anterior
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Flex(
            direction: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              Cronometro(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Observer(
              builder: (_) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      EntradaTempo(
                        titulo: 'Período de Concentração',
                        valor: store.tempoTrabalho,
                        inc: store.iniciado && store.estaTrabalhando()
                            ? null
                            : store.incrementarTempoTrabalho,
                        dec: store.iniciado && store.estaTrabalhando()
                            ? null
                            : store.decrementarTempoTrabalho,
                      ),
                      EntradaTempo(
                        titulo: 'Período de Descanso',
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      store.salvarRegistroConcentracao(store.tempoTrabalho);
                      // Tocar som para melhorar a concentração
                      soundManager.playSound('assets/concentration.mp3');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registro de Concentração Salvo!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile
                            ? 12
                            : 16, // Ajuste o tamanho verticalmente
                        horizontal: isMobile
                            ? 12
                            : 24, // Ajuste o tamanho horizontalmente
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check,
                            color: Colors.white,
                            size: isMobile
                                ? 24
                                : 32), // Ajuste o tamanho do ícone
                        SizedBox(width: 8),
                        Text(
                          'Registrar Concentração',
                          style: TextStyle(
                            fontSize:
                                isMobile ? 14 : 16, // Ajuste o tamanho da fonte
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Resto do código permanece o mesmo

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
