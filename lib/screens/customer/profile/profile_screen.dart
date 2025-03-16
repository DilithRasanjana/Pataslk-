import 'dart:io';
// Firebase Firestore for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Authentication for user management
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'edit_photo_screen.dart'; // Ensure you have an edit photo screen implemented
// Firebase Firestore and Storage helper utilities
import '../../../utils/firebase_firestore_helper.dart';
import '../../../utils/firebase_storage_helper.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;
  File? _profileImage;
  String? _profileImageUrl;

  final List<String> _genders = ['Male', 'Female'];

  bool _isLoading = true;
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firebase Firestore helper for database operations
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  // Firebase Storage helper for file operations
  final FirebaseStorageHelper _storageHelper = FirebaseStorageHelper();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Loads the current customer's profile from Firestore.
  Future<void> _loadProfile() async {
    // Get current authenticated user from Firebase
    User? user = _auth.currentUser;
    if (user != null) {
      // Get user document from Firestore using helper
      DocumentSnapshot doc = await _firestoreHelper
          .getUserStream(collection: 'customers', uid: user.uid)
          .first;
      if (doc.exists) {
        // Extract data from Firestore document
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        // Remove +94 prefix for editing.
        if (data['phone'] != null) {
          String phone = data['phone'];
          _phoneController.text = phone.startsWith('+94') ? phone.substring(3) : phone;
        }
        _emailController.text = data['email'] ?? '';
        _selectedGender = data['gender'] ?? _genders.first;
        // Convert Firestore timestamp to DateTime
        if (data['dob'] != null && data['dob'] is Timestamp) {
          _selectedDate = (data['dob'] as Timestamp).toDate();
        }
        
        // Load profile image URL from Firestore
        setState(() {
          _profileImageUrl = data['profileImageUrl'];
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// Opens a date picker for Date of Birth.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Navigates to edit photo screen and handles the result
  Future<void> _editProfilePhoto() async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPhotoScreen(currentImageUrl: _profileImageUrl),
      ),
    );
    
    if (result != null) {
      setState(() {
        _profileImage = result;
      });
      
      // Upload immediately when a new photo is selected
      _uploadProfileImage();
    }
  }

  /// Uploads the profile image to Firebase Storage
  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Get current authenticated user
    User? user = _auth.currentUser;
    if (user != null) {
      // Delete old image from Firebase Storage if it exists
      if (_profileImageUrl != null) {
        await _storageHelper.deleteFileByUrl(_profileImageUrl!);
      }
      
      // Upload new image to Firebase Storage
      String? downloadUrl = await _storageHelper.uploadFile(
        file: _profileImage!, 
        userId: user.uid, 
        folder: 'profile_images',
      );
      
      if (downloadUrl != null) {
        // Update Firestore document with new image URL
        await _firestoreHelper.saveUserData(
          collection: 'customers',
          uid: user.uid,
          data: {'profileImageUrl': downloadUrl},
        );
        
        setState(() {
          _profileImageUrl = downloadUrl;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload profile photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

 
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildProfileField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save profile logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
              Navigator.of(context).pop();
            },
            child: const Text(
              'Save Profile',
              style: TextStyle(
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: () async {
                  final File? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditPhotoScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _profileImage = result;
                    });
                    // Add a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile photo updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D47A1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Name
                  _buildProfileField(
                    'First Name',
                    _buildTextField('Enter first name', _firstNameController),
                  ),

                  // Last Name
                  _buildProfileField(
                    'Last Name',
                    _buildTextField('Enter last name', _lastNameController),
                  ),

                  // Phone Number
                  _buildProfileField(
                    'Phone Number',
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/Assets-main/Assets-main/circle 1.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '+94',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTextField(
                              'Phone number', _phoneController,
                              keyboardType: TextInputType.phone),
                        ),
                      ],
                    ),
                  ),

                  // Email
                  _buildProfileField(
                    'E-mail',
                    _buildTextField('Enter email', _emailController,
                        keyboardType: TextInputType.emailAddress),
                  ),

                  // Gender
                  _buildProfileField(
                    'Gender',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          items: ['Male', 'Female']
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedGender = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  // Date of Birth
                  _buildProfileField(
                    'Date of Birth',
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : DateFormat('dd/MM/yyyy')
                                      .format(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Colors.grey
                                    : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.calendar_today,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
