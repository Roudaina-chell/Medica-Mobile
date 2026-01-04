// pages/viewPa.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

class ViewPa extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ViewPa({Key? key, this.userData}) : super(key: key);

  @override
  State<ViewPa> createState() => _ViewPaState();
}

class _ViewPaState extends State<ViewPa> {
  Map<String, dynamic>? adminData;
  bool isLoading = true;
  int totalPatients = 0;
  int totalDoctors = 0;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => isLoading = true);

    try {
      final dbHelper = DatabaseHelper();

      if (widget.userData != null) {
        adminData = widget.userData;
      } else {
        final admin = await dbHelper.getUserByCarteId(1234567890);
        adminData = admin;
      }

      totalPatients = await dbHelper.getTotalPatients();
      totalDoctors = await dbHelper.getTotalDoctors();

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Erreur: $e');
      setState(() => isLoading = false);
    }
  }

  String getAdminName() =>
      adminData?['fullName']?.toString() ?? 'Administrateur Principal';

  String getAdminEmail() =>
      adminData?['email']?.toString() ?? 'admin@hospital.dz';

  String getAdminCarteId() =>
      adminData?['carte_id']?.toString() ?? '1234567890';

  String getAdminPhone() {
    final phone = adminData?['phone']?.toString() ?? '';
    return phone.isEmpty ? 'Non renseigné' : phone;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 90, 196, 245),
              Color.fromARGB(255, 221, 230, 235),
              Color.fromARGB(255, 214, 225, 230),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ---- tout ton design reste inchangé ----
                // (je n’ai rien supprimé ni modifié dans le style)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(count,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text("$label : $value"),
        ),
      ],
    );
  }
}
