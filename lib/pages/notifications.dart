// pages/notifications.dart
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 90, 196, 245),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.info, color: Colors.white),
            ),
            title: Text('Bienvenue'),
            subtitle: Text('Votre compte a été créé avec succès'),
            trailing: Text('Aujourd\'hui'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.event_available, color: Colors.white),
            ),
            title: Text('Rendez-vous confirmé'),
            subtitle: Text('Votre rendez-vous du 15 décembre est confirmé'),
            trailing: Text('Hier'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.medical_services, color: Colors.white),
            ),
            title: Text('Nouveau médecin disponible'),
            subtitle:
                Text('Dr. Smith est maintenant disponible pour consultation'),
            trailing: Text('Il y a 2 jours'),
          ),
        ],
      ),
    );
  }
}
