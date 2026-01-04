// pages/addP.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'database_helper.dart';

class AddPatient extends StatefulWidget {
  const AddPatient({Key? key}) : super(key: key);

  @override
  State<AddPatient> createState() => _AddPatientState();
}

class _AddPatientState extends State<AddPatient> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _carteIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;
  File? _imageFile;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genders = ['Male', 'Female'];

  @override
  void dispose() {
    _carteIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(imageBytes);

        setState(() {
          _imageFile = imageFile;
          _base64Image = base64String;
        });
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la sélection de l\'image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choisir une photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DB4F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF2DB4F6),
                ),
              ),
              title: const Text('Appareil photo 📸'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DB4F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF2DB4F6),
                ),
              ),
              title: const Text('Galerie 🖼️'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageFile != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                title: const Text('Supprimer la photo 🗑️'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageFile = null;
                    _base64Image = null;
                  });
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2DB4F6),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _addPatient() async {
    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _selectedDate != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dbHelper = DatabaseHelper();

        // Vérifier si la carte ID existe déjà
        final existingPatient = await dbHelper
            .getPatientByCarteId(int.parse(_carteIdController.text));

        if (existingPatient != null) {
          _showErrorDialog('Cette carte ID existe déjà !');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Créer le nouveau patient avec photo
        final newPatient = {
          'carte_id': int.parse(_carteIdController.text),
          'nom': _lastNameController.text.trim(),
          'prenom': _firstNameController.text.trim(),
          'date_naissance': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'sexe': _selectedGender,
          'role': 'patient',
          'photo': _base64Image, // Ajouter la photo en base64
        };

        await dbHelper.insertUser(newPatient);

        setState(() {
          _isLoading = false;
        });

        _showSuccessDialog();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Erreur lors de l\'ajout du patient: $e');
      }
    } else {
      _showErrorDialog('Veuillez remplir tous les champs');
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
        content: const Text('Patient ajouté avec succès ! ✅'),
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
                      'Add patient:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2DB4F6),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _isLoading ? null : _addPatient,
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

                        // Photo de profil avec possibilité de sélection
                        GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _imageFile == null
                                      ? Colors.black87
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  image: _imageFile != null
                                      ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _imageFile == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF2DB4F6),
                                        Color(0xFF1E88E5),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2DB4F6)
                                            .withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_imageFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Tap to change photo 📸',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        const SizedBox(height: 40),

                        // Carte ID
                        _buildTextField(
                          controller: _carteIdController,
                          label: 'National carte Id',
                          hint: 'Enter national carte ID',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la carte ID';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Entrez un numéro valide';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Prénom
                        _buildTextField(
                          controller: _firstNameController,
                          label: 'First name',
                          hint: 'Enter first name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le prénom';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Nom
                        _buildTextField(
                          controller: _lastNameController,
                          label: 'Last name',
                          hint: 'Enter last name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Date de naissance
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _dateController,
                              label: 'Date of birth',
                              hint: 'Select date',
                              icon: Icons.calendar_today_outlined,
                              suffixIcon: Icons.arrow_drop_down,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez sélectionner la date de naissance';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Genre
                        _buildGenderDropdown(),

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
    IconData? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey.shade400)
                  : null,
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
                borderSide:
                    const BorderSide(color: Color(0xFF2DB4F6), width: 2),
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
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
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
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.wc_outlined,
            color: Color(0xFF2DB4F6),
            size: 22,
          ),
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
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        hint: Text(
          'Select gender',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
        dropdownColor: Colors.white,
        items: _genders.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(
              gender,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Veuillez sélectionner le genre';
          }
          return null;
        },
      ),
    );
  }
}
