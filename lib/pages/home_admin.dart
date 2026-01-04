// pages/home_admin.dart
import 'package:flutter/material.dart';

class HomeAdmin extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeAdmin({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    String adminName = widget.userData['fullName']?.toString() ?? 'Admin';
    String adminEmail = widget.userData['email']?.toString() ?? '';
    int carteId = widget.userData['carte_id'] ?? 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 90, 196, 245),
              Color.fromARGB(255, 221, 230, 235),
              Color.fromARGB(255, 214, 225, 230),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec photo et nom
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Photo de profil
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF2DB4F6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Nom et salutation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Hi 👨‍⚕️',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          adminName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Message de bienvenue
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2DB4F6),
                      Color(0xFF1E88E5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DB4F6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Hi $adminName! ✨',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'welcome to your account',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Section Patients
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            '🏥 ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            'patients informations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Boutons patients
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildActionButton(
                            icon: Icons.person_add_outlined,
                            label: 'add',
                            emoji: '➕',
                            onTap: () {
                              Navigator.pushNamed(context, '/addP');
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: 'edit',
                            emoji: '✏️',
                            onTap: () => _showComingSoon('Modifier un patient'),
                          ),
                          const SizedBox(width: 20),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            label: 'delete',
                            emoji: '🗑️',
                            onTap: () =>
                                _showComingSoon('Supprimer un patient'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Section Doctors
                      Row(
                        children: const [
                          Text(
                            '👨‍⚕️ ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            'Doctors informations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Boutons doctors
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildActionButton(
                            icon: Icons.person_add_outlined,
                            label: 'add',
                            emoji: '➕',
                            onTap: () => _showComingSoon('Ajouter un médecin'),
                          ),
                          const SizedBox(width: 20),
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: 'edit',
                            emoji: '✏️',
                            onTap: () => _showComingSoon('Modifier un médecin'),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Informations admin en bas
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 90),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  '📋 ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Informations administrateur',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                                Icons.email_outlined, adminEmail, '📧'),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                                Icons.badge_outlined, 'ID: $carteId', '🆔'),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.admin_panel_settings_outlined,
                                'Administrateur', '👑'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 0),
            _buildNavItem(Icons.visibility_outlined, 1),
            _buildNavItem(Icons.notifications_outlined, 2),
            _buildNavItem(Icons.person_outline_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String emoji,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFF5F5F5),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF2DB4F6),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // Bouton visibility (index 1) ET bouton profil (index 3) vont vers profilAd
        if (index == 1 || index == 3) {
          Navigator.pushNamed(
            context,
            '/profilAd',
            arguments: widget.userData,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2DB4F6),
                    Color(0xFF1E88E5),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black54,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, String emoji) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: const Color(0xFF2DB4F6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🚀 ', style: TextStyle(fontSize: 18)),
            Expanded(
              child: Text('$feature - Fonctionnalité à venir'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2DB4F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
