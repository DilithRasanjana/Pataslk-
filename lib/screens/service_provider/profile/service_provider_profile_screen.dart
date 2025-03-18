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
      
      if (downloadUrl != null) {
        // Firebase Firestore: Update profile with new image URL
        await _firestoreHelper.saveUserData(
          collection: 'serviceProviders',
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

  /// Saves the profile to Firestore.
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Firebase Auth: Get current user
      User? user = _auth.currentUser;
      if (user != null) {
        // Firebase Firestore: Update user profile data
        await _firestoreHelper.saveUserData(
          collection: 'serviceProviders',
          uid: user.uid,
          data: {
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'phone': '+94' + _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'jobRole': _selectedJobRole,
            'userType': 'serviceProvider',
            'updatedAt': Timestamp.now(), // Firebase server timestamp
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user signed in'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Builds a profile field section with a label.
  Widget _buildProfileField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds a text field with consistent decoration.
  Widget _buildTextField(String hint, TextEditingController controller, {TextInputType? keyboardType, bool readOnly = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Service Provider Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save Profile',
              style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: GestureDetector(
                        onTap: _editProfilePhoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                              child: _profileImage == null
                                  ? _profileImageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: CachedNetworkImage(
                                            imageUrl: _profileImageUrl!,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                            placeholder: (context, url) => const CircularProgressIndicator(),
                                            errorWidget: (context, url, error) => 
                                                const Icon(Icons.person, size: 50, color: Colors.blue),
                                          ),
                                        )
                                      : const Icon(Icons.person, size: 50, color: Colors.blue)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D47A1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          // Phone Number (with "+94" displayed separately)
                          _buildProfileField(
                            'Phone Number',
                            Row(
                              children: [
                                const Text('+94 '),
                                Expanded(
                                  child: _buildTextField('Enter phone number', _phoneController, keyboardType: TextInputType.phone),
                                ),
                              ],
                            ),
                          ),
                          // Email (read-only)
                          _buildProfileField(
                            'E-mail',
                            _buildTextField('Enter email', _emailController, keyboardType: TextInputType.emailAddress, readOnly: true),
                          ),
                          // Job Role (dropdown)
                          _buildProfileField(
                            'Job Role',
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedJobRole,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                hint: const Text('Select job role'),
                                items: _jobRoles.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedJobRole = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a job role';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D47A1),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
            ),
    );
  }
}
