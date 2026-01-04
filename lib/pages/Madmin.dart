// pages/Madmin.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

class ModifierAdmin extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ModifierAdmin({Key? key, this.userData}) : super(key: key);

  @override
  State<ModifierAdmin> createState() => _ModifierAdminState();
}

class _ModifierAdminState extends State<ModifierAdmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? adminData;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final dbHelper = DatabaseHelper();

      if (widget.userData != null) {
        adminData = widget.userData;
      } else {
        adminData = await dbHelper.getUserByCarteId(1234567890);
      }

      if (adminData != null) {
        _nameController.text = adminData!['fullName']?.toString() ?? '';
        _emailController.text = adminData!['email']?.toString() ?? '';
        _phoneController.text = adminData!['phone']?.toString() ?? '';
        _addressController.text = adminData!['address']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Erreur chargement admin: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dbHelper = DatabaseHelper();

        // Mettre à jour les données
        final updatedData = {
          ...adminData!,
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        };

        // Sauvegarder dans Hive
        await dbHelper.updateUser(_emailController.text.trim(), updatedData);

        setState(() {
          _isLoading = false;
        });

        _showSuccessDialog();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Erreur lors de la mise à jour: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Succès'),
          ],
        ),
        content: const Text('Profil mis à jour avec succès ! ✅'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF2DB4F6)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF2DB4F6)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF2DB4F6),
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Modifier Profil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2DB4F6),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _isLoading ? null : _updateProfile,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? Colors.grey.withOpacity(0.5)
                              : const Color(0xFF2DB4F6),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // Formulaire
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Photo de profil
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                size: 60,
                                color: Color(0xFF2DB4F6),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.orange, Colors.deepOrange],
                                  ),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Nom complet
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nom complet',
                          hint: 'Entrez votre nom',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Email
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Entrez votre email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Téléphone
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Téléphone',
                          hint: 'Entrez votre numéro',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 16),

                        // Adresse
                        _buildTextField(
                          controller: _addressController,
                          label: 'Adresse',
                          hint: 'Entrez votre adresse',
                          icon: Icons.location_on_outlined,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 40),

                        // Note informative
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Note: Le numéro de carte nationale ne peut pas être modifié.',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF2DB4F6), size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2DB4F6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
