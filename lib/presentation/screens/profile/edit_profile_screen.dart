import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/campus/campus_provider.dart';
import '../../../data/models/campus_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  List<String> _selectedDepartments = [];
  String? _selectedCampusId;
  XFile? _selectedImage;
  bool _isLoading = false;

  final List<String> _availableDepartments = [
    'Business Administration',
    'Economics',
    'Marketing',
    'Finance',
    'International Business',
    'Technology Management',
    'HR Management',
    'Strategy & Leadership',
    'Accounting',
    'Innovation & Entrepreneurship',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
      _zipController.text = user.zipCode ?? '';
      _selectedDepartments = List.from(user.departments);
      _selectedCampusId = user.campusId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        zipCode: _zipController.text.trim().isNotEmpty ? _zipController.text.trim() : null,
        campusId: _selectedCampusId,
        departments: _selectedDepartments,
        avatarFile: _selectedImage,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.green9,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final allCampuses = ref.watch(allCampusesProvider);
    final profileCampus = ref.watch(profileCampusProvider);
    final selectedCampus = profileCampus ?? CampusData.defaultCampus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getCampusColor(selectedCampus.id),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path)) as ImageProvider
                            : (authState.user?.avatarUrl != null
                                ? NetworkImage(authState.user!.avatarUrl!)
                                : null),
                        backgroundColor: AppColors.gray200,
                        child: (_selectedImage == null && authState.user?.avatarUrl == null)
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: _getCampusColor(selectedCampus.id),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getCampusColor(selectedCampus.id),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Personal Information
              Text(
                'Personal Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.strongBlue,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  hintText: '+47 123 45 678',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Basic Norwegian phone number validation
                    final phoneRegex = RegExp(r'^\+47\s?\d{8}$|^\d{8}$');
                    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                      return 'Please enter a valid Norwegian phone number';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Address Information
              Text(
                'Address Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.strongBlue,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  prefixIcon: const Icon(Icons.home_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: l10n.city,
                        prefixIcon: const Icon(Icons.location_city_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _zipController,
                      decoration: InputDecoration(
                        labelText: l10n.zipCode,
                        prefixIcon: const Icon(Icons.local_post_office_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Norwegian postal code validation (4 digits)
                          if (value.length != 4 || !RegExp(r'^\d{4}$').hasMatch(value)) {
                            return 'Invalid zip code';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Interests/Departments
              Text(
                'Interests & Departments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.strongBlue,
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ...List.generate(_availableDepartments.length, (index) {
                        final department = _availableDepartments[index];
                        final isSelected = _selectedDepartments.contains(department);

                        return CheckboxListTile(
                          title: Text(department),
                          value: isSelected,
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedDepartments.add(department);
                              } else {
                                _selectedDepartments.remove(department);
                              }
                            });
                          },
                          activeColor: _getCampusColor(selectedCampus.id),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Campus Information
              Text(
                'Campus Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.strongBlue,
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select your home campus',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...allCampuses.map((campus) {
                        final isSelected = _selectedCampusId == campus.id;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCampusId = campus.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? _getCampusColor(campus.id)
                                      : AppColors.outline,
                                  width: isSelected ? 2 : 1,
                                ),
                                color: isSelected
                                    ? _getCampusColor(campus.id).withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getCampusColor(campus.id),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_city,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'BI ${campus.name}',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        Text(
                                          campus.description,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: _getCampusColor(campus.id),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCampusColor(String campusId) {
    switch (campusId) {
      case 'oslo':
        return AppColors.defaultBlue;
      case 'bergen':
        return AppColors.green9;
      case 'trondheim':
        return AppColors.purple9;
      case 'stavanger':
        return AppColors.orange9;
      default:
        return AppColors.gray400;
    }
  }
}