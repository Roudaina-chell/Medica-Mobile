import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// Importez vos pages ici:
// import 'SecurityPage.dart';
// import 'AboutPage.dart';
// import 'SignUp.dart';

class ProfileM extends StatefulWidget {
  const ProfileM({Key? key}) : super(key: key);

  @override
  State<ProfileM> createState() => _ProfileMState();
}

class _ProfileMState extends State<ProfileM> {
  final TextEditingController firstNameController =
      TextEditingController(text: 'Chelloug');
  final TextEditingController lastNameController =
      TextEditingController(text: 'Roudaina');
  final TextEditingController dateController =
      TextEditingController(text: '25/07/2005');
  final TextEditingController contactController =
      TextEditingController(text: '0550304771');
  String selectedGender = 'Female';

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Color(0xFF4FC3F7)),
                  title: Text('Choisir depuis la galerie'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Color(0xFF4FC3F7)),
                  title: Text('Prendre une photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 7, 25),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF4FC3F7),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
      setState(() {
        dateController.text = formattedDate;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('Déconnexion'),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialog
                // Décommentez cette ligne et importez SignUp.dart:
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(builder: (context) => SignUp()),
                //   (route) => false,
                // );

                // Pour le moment, afficher un message:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Déconnexion réussie!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Déconnexion', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
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
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            size: 24, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.check, size: 24, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: Color(0xFF4FC3F7),
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Profile Image with Camera Icon
              Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                      image: _selectedImage == null
                          ? DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: 130,
                              height: 130,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black87,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Form Container
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'First name',
                          controller: firstNameController,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          label: 'Last name',
                          controller: lastNameController,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          label: 'Date of birth',
                          controller: dateController,
                          suffixIcon: Icons.calendar_today,
                          onTap: () => _selectDate(context),
                          readOnly: true,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          label: 'Contact info',
                          controller: contactController,
                        ),
                        SizedBox(height: 20),
                        _buildGenderDropdown(),

                        // Logout Button
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, true),
          _buildNavItem(Icons.receipt_long_outlined, false),
          _buildNavItem(Icons.medical_services_outlined, false),
          _buildNavItem(Icons.calendar_month_outlined, false),
          _buildNavItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF2196F3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.grey[600],
        size: 24,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey[500], size: 20)
                  : null,
            ),
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedGender,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            items: ['Male', 'Female', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedGender = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDestructive ? Colors.red.withOpacity(0.2) : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Color(0xFF4FC3F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Color(0xFF4FC3F7),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? Colors.red : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dateController.dispose();
    contactController.dispose();
    super.dispose();
  }
}