// pages/Profile.dart
import 'package:flutter/material.dart';
import 'ProfileM.dart';

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
        'icon': Icons.visibility_outlined,
        'color': Colors.orange,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voir le profil'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      },
      {
        'title': 'Security',
        'icon': Icons.shield_outlined,
        'color': Colors.pink,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paramètres de sécurité'),
              backgroundColor: Colors.pink,
            ),
          );
        },
      },
      {
        'title': 'Notification',
        'icon': Icons.notifications_outlined,
        'color': Colors.blue,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications'),
              backgroundColor: Colors.blue,
            ),
          );
        },
      },
      {
        'title': 'Help',
        'icon': Icons.help_outline,
        'color': Colors.green,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aide'),
              backgroundColor: Colors.green,
            ),
          );
        },
      },
      {
        'title': 'Log Out',
        'icon': Icons.logout,
        'color': Colors.red,
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
            'color': Colors.blue,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Liste des patients'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          },
          ...commonOptions,
        ];

      case 'patient':
        return [
          {
            'title': 'Modified',
            'icon': Icons.edit_outlined,
            'color': Colors.blue,
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

      case 'administration':
        return [
          {
            'title': 'Affecter Rendez-vous',
            'icon': Icons.schedule_outlined,
            'color': Colors.purple,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Affecter les rendez-vous'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
          },
          {
            'title': 'Modified',
            'icon': Icons.edit_outlined,
            'color': Colors.blue,
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
            'color': Colors.blue,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Liste des patients'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          },
          {
            'title': 'Visualiser Médecins',
            'icon': Icons.medical_services_outlined,
            'color': Colors.green,
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Liste des médecins'),
                  backgroundColor: Colors.green,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7DD3FC), // Light blue
              Color(0xFFBAE6FD), // Lighter blue
              Color(0xFFE0F2FE), // Very light blue
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Profile Avatar with online indicator
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E3A5F),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Menu List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    itemCount: menuOptions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final option = menuOptions[index];
                      final iconColor = option['color'] as Color;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          leading: Icon(
                            option['icon'] as IconData,
                            color: iconColor,
                            size: 26,
                          ),
                          title: Text(
                            option['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          onTap: option['action'] as void Function()?,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}