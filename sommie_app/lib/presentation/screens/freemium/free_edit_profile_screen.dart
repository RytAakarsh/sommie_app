import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/storage_helper.dart';

class FreeEditProfileScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FreeEditProfileScreen({
    super.key,
    required this.onBack,
  });

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
  
  String _selectedAvatar = '';
  String _selectedGender = '';
  String _selectedRole = '';
  String _selectedAvatarName = '';
  
  final List<Map<String, String>> _avatars = [
    {
      'name': 'Lucía Herrera',
      'role': 'Regional Specialist',
      'img': 'assets/images/avatars/Avatar_Sommie_Lucia_Herrera.png',
    },
    {
      'name': 'Li Wei',
      'role': 'Precision Sommelier',
      'img': 'assets/images/avatars/Avatar_Sommie_LiWei.png',
    },
    {
      'name': 'Karim Al-Nassir',
      'role': 'Global Pairing Expert',
      'img': 'assets/images/avatars/Avatar_Sommie_karim_Al-Nassir.png',
    },
    {
      'name': 'Ama Kumasi',
      'role': 'Warm-Climate Enthusiast',
      'img': 'assets/images/avatars/Avatar_Sommie_Ama_Kumasi.png',
    },
    {
      'name': 'Dom Aurelius',
      'role': 'Expert in classic Wines',
      'img': 'assets/images/avatars/Avatares_sommie_Dom_Aurelius.png',
    },
    {
      'name': 'Amelie',
      'role': 'Trend Enthusiast',
      'img': 'assets/images/avatars/Avatares Sommie_Amelie.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cpfController = TextEditingController();
    _addressController = TextEditingController();
    _dobController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    final user = await StorageHelper.getUser();
    final profile = await StorageHelper.getUserProfile();
    
    setState(() {
      _nameController.text = user?.name ?? profile?['name'] ?? '';
      _emailController.text = user?.email ?? profile?['email'] ?? '';
      _phoneController.text = profile?['phone'] ?? '';
      _cpfController.text = profile?['cpf'] ?? '';
      _addressController.text = profile?['address'] ?? '';
      _dobController.text = profile?['dob'] ?? '';
      _selectedGender = profile?['gender'] ?? '';
      _selectedAvatar = user?.avatar ?? profile?['avatar'] ?? '';
      _selectedRole = user?.role ?? profile?['role'] ?? '';
      
      final selected = _avatars.firstWhere(
        (a) => a['img'] == _selectedAvatar,
        orElse: () => {},
      );
      _selectedAvatarName = selected['name'] ?? '';
    });
  }

Future<void> _saveProfile() async {
  if (_formKey.currentState?.validate() ?? false) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) return;
    
    final selectedAvatar = _avatars.firstWhere(
      (a) => a['img'] == _selectedAvatar,
      orElse: () => {'role': _selectedRole},
    );
    
    final updatedUser = currentUser.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      avatar: _selectedAvatar,
      role: selectedAvatar['role'] ?? _selectedRole,
    );
    
    print('💾 Saving profile with avatar: $_selectedAvatar');
    print('💾 Role: ${selectedAvatar['role']}');
    
    // Save to auth provider
    await authProvider.updateUser(updatedUser);
    
    // Double-check that it saved
    final savedUser = await StorageHelper.getUser();
    print('✅ Verification - Saved user avatar: ${savedUser?.avatar}');
    
    if (mounted) {
      widget.onBack();
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Edit Your Profile',
          style: TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select the Avatar that better represent you',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._avatars.map((avatar) => _buildAvatarTile(avatar)),
              
              const SizedBox(height: 24),
              
              const Text(
                'Edit User info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: 'Phone number',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _cpfController,
                      label: 'CPF',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _addressController,
                label: 'Address',
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _dobController,
                      label: 'Date of birth',
                      hintText: 'YYYY-MM-DD',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4B2B5F),
                        side: const BorderSide(color: Color(0xFF4B2B5F)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B2B5F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarTile(Map<String, String> avatar) {
    final isSelected = _selectedAvatar == avatar['img'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = avatar['img']!;
          _selectedRole = avatar['role']!;
          _selectedAvatarName = avatar['name']!;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE9D6FF)
              : const Color(0xFFEBE5F0),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF4B2B5F), width: 2)
              : null,
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                avatar['img']!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFF4B2B5F),
                    child: Center(
                      child: Text(
                        avatar['name']![0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avatar['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B2B5F),
                    ),
                  ),
                  Text(
                    avatar['role']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6D3FA6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4B2B5F),
                size: 24,
              ),
          ],
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF5EEF8),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender.isEmpty ? null : _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF5EEF8),
      ),
      items: const [
        DropdownMenuItem(
          value: 'male',
          child: Text('Male'),
        ),
        DropdownMenuItem(
          value: 'female',
          child: Text('Female'),
        ),
        DropdownMenuItem(
          value: 'other',
          child: Text('Other'),
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
