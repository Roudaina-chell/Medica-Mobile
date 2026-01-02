// pages/Profile.dart
import 'package:flutter/material.dart';
import 'ProfileM.dart'; // Import corrigé

class Profile extends StatelessWidget {
  final String username;
  final String email;
  final String? role;

  const Profile({
    Key? key,
    required this.username,
    required this.email,
    this.role,
  }) : super(key: key);

  String getRoleLabel() {
    final currentRole = role ?? 'patient';
    switch (currentRole) {
      case 'doctor':
        return 'Médecin';
      case 'admin':
        return 'Administrateur';
      case 'administration':
        return 'Administration';
      default:
        return 'Patient';
    }
  }

  IconData getRoleIcon() {
    final currentRole = role ?? 'patient';
    switch (currentRole) {
      case 'doctor':
        return Icons.medical_services;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'administration':
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  Color getRoleColor() {
    final currentRole = role ?? 'patient';
    switch (currentRole) {
      case 'doctor':
        return Colors.green;
      case 'admin':
        return Colors.orange;
      case 'administration':
        return Colors.purple;
      default:
        return const Color(0xFF2DB4F6);
    }
  }

  String getRoleDescription() {
    final currentRole = role ?? 'patient';
    switch (currentRole) {
      case 'doctor':
        return 'Accès complet aux fonctionnalités médicales';
      case 'admin':
        return 'Accès administrateur système';
      case 'administration':
        return 'Gestion administrative';
      default:
        return 'Accès patient standard';
    }
  }

  List<Map<String, dynamic>> getMenuOptions(BuildContext context) {
    final currentRole = role ?? 'patient';

    List<Map<String, dynamic>> commonOptions = [
      {
        'title': 'View Profile',
        'icon': Icons.person_outline,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Voir le profil'),
              backgroundColor: getRoleColor(),
            ),
          );
        },
      },
      {
        'title': 'Security',
        'icon': Icons.security_outlined,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Paramètres de sécurité'),
              backgroundColor: getRoleColor(),
            ),
          );
        },
      },
      {
        'title': 'Notification',
        'icon': Icons.notifications_outlined,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notifications'),
              backgroundColor: getRoleColor(),
            ),
          );
        },
      },
      {
        'title': 'Help',
        'icon': Icons.help_outline,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Aide'),
              backgroundColor: getRoleColor(),
            ),
          );
        },
      },
      {
        'title': 'Log Out',
        'icon': Icons.logout,
        'action': () {
          _showLogoutDialog(context);
        },
      },
    ];

    switch (currentRole) {
      case 'doctor':
        return [
          {
            'title': 'Mes Patients',
            'icon': Icons.group_outlined,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Liste des patients'),
                  backgroundColor: getRoleColor(),
                ),
              );
            },
          },
          ...commonOptions,
        ];

      case 'patient':
        return [
          {
            'title': 'Modifier Profile',
            'icon': Icons.edit_outlined,
            'action': () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    userEmail: email,
                  ),
                ),
              );

              if (result != null && result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil mis à jour avec succès'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          },
          {
            'title': 'Liste des Médecins',
            'icon': Icons.medical_services_outlined,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Liste des médecins'),
                  backgroundColor: getRoleColor(),
                ),
              );
            },
          },
          {
            'title': 'Demander Rendez-vous',
            'icon': Icons.calendar_today_outlined,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Demander un rendez-vous'),
                  backgroundColor: getRoleColor(),
                ),
              );
            },
          },
          ...commonOptions,
        ];

      case 'administration':
        return [
          {
            'title': 'Affecter Rendez-vous',
            'icon': Icons.schedule_outlined,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Affecter les rendez-vous'),
                  backgroundColor: getRoleColor(),
                ),
              );
            },
          },
          {
            'title': 'Modifier Profile',
            'icon': Icons.edit_outlined,
            'action': () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    userEmail: email,
                  ),
                ),
              );

              if (result != null && result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil mis à jour avec succès'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          },
          ...commonOptions,
        ];

      case 'admin':
        return [
          {
            'title': 'Visualiser Patients',
            'icon': Icons.group_outlined,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Liste des patients'),
                  backgroundColor: getRoleColor(),
                ),
              );
            },
          },
          {
            'title': 'Visualiser Médecins',
            'icon': Icons.medical_services_outlined,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Liste des médecins'),
                  backgroundColor: getRoleColor(),
                ),
              );
            },
          },
          ...commonOptions,
        ];

      default:
        return commonOptions;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuOptions = getMenuOptions(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: getRoleColor(),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: getRoleColor(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      getRoleIcon(),
                      size: 50,
                      color: getRoleColor(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getRoleLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getRoleColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: getRoleColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: getRoleColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      getRoleDescription(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuOptions.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = menuOptions[index];
                      final isLogout = option['title'] == 'Log Out';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isLogout
                                  ? Colors.red.withOpacity(0.1)
                                  : getRoleColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              option['icon'] as IconData,
                              color: isLogout ? Colors.red : getRoleColor(),
                              size: 22,
                            ),
                          ),
                          title: Text(
                            option['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: isLogout ? Colors.red : Colors.black87,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: isLogout ? Colors.red : getRoleColor(),
                          ),
                          onTap: option['action'] as void Function()?,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
