// pages/viewPa.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

class ViewProfileAdmin extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ViewProfileAdmin({Key? key, this.userData}) : super(key: key);

  @override
  State<ViewProfileAdmin> createState() => _ViewProfileAdminState();
}

class _ViewProfileAdminState extends State<ViewProfileAdmin> {
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
      appBar: AppBar(
        title: const Text("Profil Administrateur"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nom : ${getAdminName()}",
                style: const TextStyle(fontSize: 20)),
            Text("Email : ${getAdminEmail()}"),
            Text("Carte ID : ${getAdminCarteId()}"),
            Text("Téléphone : ${getAdminPhone()}"),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.people,
                  label: "Patients",
                  count: totalPatients.toString(),
                  color: Colors.green,
                ),
                _buildStatCard(
                  icon: Icons.medical_services,
                  label: "Doctors",
                  count: totalDoctors.toString(),
                  color: Colors.blue,
                ),
              ],
            )
          ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(count,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label),
        ],
      ),
    );
  }
}
