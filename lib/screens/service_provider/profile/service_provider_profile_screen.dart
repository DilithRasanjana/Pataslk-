import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/firebase_firestore_helper.dart';
import '../../../utils/firebase_storage_helper.dart';
import 'service_provider_photo_upload_screen.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  State<ServiceProviderProfileScreen> createState() => _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState extends State<ServiceProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedJobRole;
  File? _profileImage;
  String? _profileImageUrl;

  final List<String> _jobRoles = [
    'AC Repair',
    'Beauty',
    'Appliance',
    'Painting',
    'Cleaning',
    'Plumbing',
    'Electronics',
    'Men\'s Salon',
    'Shifting'
  ];

  bool _isLoading = true;
  // Firebase Auth: Access to authentication services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firebase Firestore: Helper for database operations
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  // Firebase Storage: Helper for file storage operations
  final FirebaseStorageHelper _storageHelper = FirebaseStorageHelper();

 @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Loads the current service provider's profile from Firestore.
  Future<void> _loadProfile() async {
    // Firebase Auth: Get current user
    User? user = _auth.currentUser;
     if (user != null) {
      // Firebase Firestore: Get provider document from serviceProviders collection
      DocumentSnapshot doc = await _firestoreHelper
          .getUserStream(collection: 'serviceProviders', uid: user.uid)
          .first;
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        // Remove +94 prefix for editing.
        if (data['phone'] != null) {
          String phone = data['phone'];
          _phoneController.text = phone.startsWith('+94') ? phone.substring(3) : phone;
        }
        _emailController.text = data['email'] ?? '';
        _selectedJobRole = data['jobRole'];
        
        // Load profile image URL if stored
        setState(() {
          _profileImageUrl = data['profileImageUrl'];
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// Updates the profile image by navigating to the photo upload screen
  Future<void> _editProfilePhoto() async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServiceProviderPhotoUploadScreen(),
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

     // Firebase Auth: Get current user
    User? user = _auth.currentUser;
    if (user != null) {
      // Firebase Storage: Delete old image if exists
      if (_profileImageUrl != null) {
        await _storageHelper.deleteFileByUrl(_profileImageUrl!);
      }
      
      // Firebase Storage: Upload new image
      String? downloadUrl = await _storageHelper.uploadFile(
        file: _profileImage!, 
        userId: user.uid, 
        folder: 'profile_images',
      );
  final List<String> _districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya'
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Save profile logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final File? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ServiceProviderPhotoUploadScreen(),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _profileImage = result;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Profile photo updated successfully'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.blue,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[900],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                          border: UnderlineInputBorder(),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoSection(
                  'Phone Number',
                  Row(
                    children: [
                      Image.asset(
                        'assets/Assets-main/Assets-main/circle 1.png', // Updated to use local asset
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '+94',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Enter phone number',
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length != 10) {
                              return 'Phone number must be 10 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _buildInfoSection(
                  'E-mail',
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                _buildInfoSection(
                  'Date of Birth',
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1923),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildInfoSection(
                  'Gender',
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      hintText: 'Select gender',
                      border: InputBorder.none,
                    ),
                    items: _genders.map((String gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                ),
                _buildInfoSection(
                  'Occupation',
                  DropdownButtonFormField<String>(
                    value: _selectedOccupation,
                    decoration: const InputDecoration(
                      hintText: 'Select occupation',
                      border: InputBorder.none,
                    ),
                    items: _occupations.map((String occupation) {
                      return DropdownMenuItem(
                        value: occupation,
                        child: Text(occupation),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOccupation = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your occupation';
                      }
                      return null;
                    },
                  ),
                ),
                _buildInfoSection(
                  'Operating Districts',
                  Column(
                    children: [
                      MultiSelectDialogField<String>(
                        items: _districts
                            .map((district) => MultiSelectItem<String>(
                                  district,
                                  district,
                                ))
                            .toList(),
                        initialValue: _selectedDistricts,
                        title: const Text("Select Districts"),
                        selectedColor: Colors.blue,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        buttonIcon: const Icon(Icons.arrow_drop_down),
                        buttonText: Text(
                          _selectedDistricts.isEmpty
                              ? "Select operating districts"
                              : "${_selectedDistricts.length} districts selected",
                        ),
                        onConfirm: (results) {
                          setState(() {
                            _selectedDistricts = results;
                          });
                        },
                        validator: (values) {
                          if (values == null || values.isEmpty) {
                            return 'Please select at least one district';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      MultiSelectChipDisplay<String>(
                        items: _selectedDistricts
                            .map((district) =>
                                MultiSelectItem<String>(district, district))
                            .toList(),
                        onTap: (value) {
                          setState(() {
                            _selectedDistricts.remove(value);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: content,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
