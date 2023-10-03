import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  List<String> notifications = []; // Lista para armazenar notificações

  @override
  void initState() {
    super.initState();

    // Configurar um listener para receber notificações em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Aqui você pode tratar a notificação recebida em primeiro plano
      setState(() {
        notifications.add(
            "Notificação em primeiro plano: ${message.notification?.title}");
      });
    });

    // Solicitar permissão para receber notificações (opcional)
    _firebaseMessaging.requestPermission();

    // Inicialmente, você pode obter as notificações armazenadas localmente (se houver)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        setState(() {
          notifications.add(
              "Notificação em primeiro plano: ${message.notification?.title}");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Notificações'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notifications[index]),
          );
        },
      ),
    );
  }
}
