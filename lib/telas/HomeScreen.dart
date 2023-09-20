import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tdah_app/telas/Dashaboard.dart';
import 'package:tdah_app/telas/cards_op.dart';

import 'package:tdah_app/telas/notification_screen.dart';
import 'package:tdah_app/telas/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();

    // Configurar a função de callback para receber notificações
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Ao receber uma nova notificação, atualize a contagem
      setState(() {
        notificationCount++;
      });
    });
  }

  // Restante do código da tela HomeScreen (o mesmo que você já tinha)

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Função para navegar para a tela de notificações
    void navigateToNotificationsScreen() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NotificationsScreen(),
        ),
      );
    }

    // Função para exibir o BottomSheet com opções
    void showOptionsBottomSheet() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.today),
                  title: const Text('O que vamos fazer hoje?'),
                  onTap: () {
                    // Implemente a lógica para a ação "O que vamos fazer hoje?"
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Lembrar de algo?'),
                  onTap: () {
                    // Implemente a lógica para a ação "Lembrar de algo?"
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sentiment_satisfied),
                  title: const Text('Controlar meus sentimentos'),
                  onTap: () {
                    // Implemente a lógica para a ação "Controlar meus sentimentos"
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('Cadastrar meus medicamentos'),
                  onTap: () {
                    // Implemente a lógica para a ação "Cadastrar meus medicamentos"
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Image.asset('assets/letra.png'),
        actions: [
          // Adicione um botão para visualizar notificações
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (notificationCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        notificationCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: navigateToNotificationsScreen,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Navegar de volta para a tela de login após sair
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      drawer: const SideBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Olá, ${user?.displayName}!',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const DashboardProgress(),
            const SizedBox(height: 16.0),
            const FilterOptions(),
            const SizedBox(height: 16.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                return OptionCard(
                  icon: options[index].icon,
                  title: options[index].title,
                  page: options[index].page,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Container(
          height: 64.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: InkWell(
            onTap: showOptionsBottomSheet,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'O que vamos fazer hoje?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Toque aqui para ver opções',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
