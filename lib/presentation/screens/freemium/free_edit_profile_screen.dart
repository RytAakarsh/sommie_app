import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../core/utils/storage_helper.dart';
import 'free_choose_avatar_screen.dart';

class FreeEditProfileScreen extends StatefulWidget {
  const FreeEditProfileScreen({super.key});

  @override
  State<FreeEditProfileScreen> createState() => _FreeEditProfileScreenState();
}

class _FreeEditProfileScreenState extends State<FreeEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cpfController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  
  String _selectedGender = '';
  String? _photoUrl;
  String _currentAvatar = '';
  String _currentAvatarName = '';
  bool _isSaving = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cpfController = TextEditingController();
    _addressController = TextEditingController();
    _dobController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUser();
      
      if (!mounted) return;
      
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('User not found');
      }

      setState(() {
        _nameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
        _cpfController.text = user.cpf ?? '';
        _addressController.text = user.address ?? '';
        _dobController.text = user.dob ?? '';
        _selectedGender = user.gender ?? '';
        _photoUrl = user.photo;
        _currentAvatar = user.avatar ?? '';
        
        final avatarNames = {
          'assets/sommie_avatar/Avatar_Sommie_Lucia_Herrera.png': 'Lucía Herrera',
          'assets/sommie_avatar/Avatar_Sommie_LiWei.png': 'Li Wei',
          'assets/sommie_avatar/Avatar_Sommie_karim_Al-Nassir.png': 'Karim Al-Nassir',
          'assets/sommie_avatar/Avatar_Sommie_Ama_Kumasi.png': 'Ama Kumasi',
          'assets/sommie_avatar/Avatares_sommie_Dom_Aurelius.png': 'Miguel',
          'assets/sommie_avatar/Avatares_Sommie_Amelie.png': 'Amelie',
        };
        _currentAvatarName = avatarNames[_currentAvatar] ?? 'Sommie';
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading user data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        String photoUrl;
        
        if (kIsWeb) {
          final base64Image = base64Encode(bytes);
          photoUrl = 'data:image/jpeg;base64,$base64Image';
        } else {
          final originalImage = img.decodeImage(bytes);
          if (originalImage != null) {
            final compressedBytes = img.encodeJpg(originalImage, quality: 60);
            final base64Image = base64Encode(compressedBytes);
            photoUrl = 'data:image/jpeg;base64,$base64Image';
          } else {
            final base64Image = base64Encode(bytes);
            photoUrl = 'data:image/jpeg;base64,$base64Image';
          }
        }
        
        setState(() {
          _photoUrl = photoUrl;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    // Validate form first
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final profileData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'address': _addressController.text.trim(),
        'dob': _dobController.text.trim(),
        'gender': _selectedGender,
        if (_photoUrl != null && _photoUrl!.isNotEmpty) 'photo': _photoUrl,
      };
      
      await authProvider.updateProfile(profileData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save profile';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildProfileImage() {
    if (_photoUrl == null || _photoUrl!.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Color(0xFF4B2B5F));
    }
    
    try {
      if (_photoUrl!.contains(',')) {
        final base64String = _photoUrl!.split(',').last;
        final bytes = base64Decode(base64String);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) {
              return const Icon(Icons.person, size: 50, color: Color(0xFF4B2B5F));
            },
          ),
        );
      } else if (_photoUrl!.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            _photoUrl!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) {
              return const Icon(Icons.person, size: 50, color: Color(0xFF4B2B5F));
            },
          ),
        );
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    
    return const Icon(Icons.person, size: 50, color: Color(0xFF4B2B5F));
  }

  Widget _buildCurrentAvatar() {
    if (_currentAvatar.isEmpty || !_currentAvatar.startsWith('assets/')) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFF4B2B5F),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 30),
      );
    }
    
    return ClipOval(
      child: Image.asset(
        _currentAvatar,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF4B2B5F),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F1F1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isPT ? 'Editar Perfil' : 'Edit Profile',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF3E8FF),
                        ),
                        child: Center(child: _buildProfileImage()),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF4B2B5F),
                            shape: BoxShape.circle,
                          ),
                          child: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'camera') {
                                _pickImage(ImageSource.camera);
                              } else if (value == 'gallery') {
                                _pickImage(ImageSource.gallery);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'camera',
                                child: Row(
                                  children: [
                                    Icon(Icons.camera_alt, size: 20),
                                    SizedBox(width: 12),
                                    Text('Camera'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'gallery',
                                child: Row(
                                  children: [
                                    Icon(Icons.photo_library, size: 20),
                                    SizedBox(width: 12),
                                    Text('Gallery'),
                                  ],
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildCurrentAvatar(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPT ? 'Avatar Atual' : 'Current Avatar',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _currentAvatarName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B2B5F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IntrinsicWidth(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FreeChooseAvatarScreen(
                                    onAvatarSelected: () {},
                                  ),
                                ),
                              );
                              _loadUserData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7f488b),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(isPT ? 'Alterar' : 'Change'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                const Divider(),
                const SizedBox(height: 16),
                
                Text(
                  isPT ? 'Editar Informações' : 'Edit User Info',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nameController,
                  label: isPT ? 'Nome' : 'Name',
                  validator: (v) => v == null || v.isEmpty ? (isPT ? 'Nome obrigatório' : 'Name required') : null,
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  enabled: false,
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: isPT ? 'Telefone' : 'Phone',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _cpfController,
                        label: 'CPF',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _addressController,
                  label: isPT ? 'Endereço' : 'Address',
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _dobController,
                        label: isPT ? 'Data Nascimento' : 'Date of Birth',
                        hintText: 'YYYY-MM-DD',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderDropdown(isPT),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4B2B5F),
                          side: const BorderSide(color: Color(0xFF4B2B5F)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isPT ? 'Cancelar' : 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2B5F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isPT ? 'Salvar' : 'Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hintText,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF5EEF8) : const Color(0xFFEEEEEE),
      ),
    );
  }

  Widget _buildGenderDropdown(bool isPT) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // ✅ FIX: Prevents overflow
      value: _selectedGender.isEmpty ? null : _selectedGender,
      decoration: InputDecoration(
        labelText: isPT ? 'Gênero' : 'Gender',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF5EEF8),
      ),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),
        DropdownMenuItem(value: 'other', child: Text('Other')),
        DropdownMenuItem(
          value: 'prefer-not-to-say',
          child: Text('Prefer not to say', overflow: TextOverflow.ellipsis),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value ?? '';
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}