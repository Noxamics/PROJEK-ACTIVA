import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfilScreen extends ConsumerStatefulWidget {
  const EditProfilScreen({super.key});

  @override
  ConsumerState<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends ConsumerState<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;

  String? _selectedGender;
  String? _selectedEducation;
  String? _selectedIncome;
  String? _selectedRegion;
  String? _selectedRole;
  DateTime? _selectedDob;

  // Options matching RegisterScreen
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _pendidikanOptions = [
    'SMA/SMK/Sederajat',
    'Sarjana',
    'Magister',
    'Doktor',
  ];
  final List<String> _regionOptions = [
    'Afrika',
    'Asia',
    'Eropa',
    'Timur Tengah',
    'Amerika Utara',
    'Amerika Selatan',
  ];
  final List<String> _roleOptions = [
    'Pelajar/Mahasiswa',
    'Karyawan Penuh waktu',
    'Karyawan Paruh waktu',
    'Pengurus rumah tangga',
    'Tidak bekerja/sedang mencari kerja',
  ];
  final List<String> _incomeOptions = [
    'Rendah',
    'Menengah Bawah',
    'Menengah Atas',
    'Tinggi',
  ];

  // Mapping from DB (English) to UI (Indonesian)
  final _genderToIndo = {'Male': 'Laki-laki', 'Female': 'Perempuan'};
  final _eduToIndo = {
    'High School': 'SMA/SMK/Sederajat',
    'Bachelor': 'Sarjana',
    'Master': 'Magister',
    'PhD': 'Doktor',
  };
  final _regionToIndo = {
    'Africa': 'Afrika',
    'Asia': 'Asia',
    'Europe': 'Eropa',
    'Middle East': 'Timur Tengah',
    'North America': 'Amerika Utara',
    'South America': 'Amerika Selatan',
  };
  final _roleToIndo = {
    'Student': 'Pelajar/Mahasiswa',
    'Full-time': 'Karyawan Penuh waktu',
    'Part-time': 'Karyawan Paruh waktu',
    'Caregiver': 'Pengurus rumah tangga',
    'Unemployed': 'Tidak bekerja/sedang mencari kerja',
  };
  final _incomeToIndo = {
    'Low': 'Rendah',
    'Lower-Mid': 'Menengah Bawah',
    'Upper-Mid': 'Menengah Atas',
    'High': 'Tinggi',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    
    // Set default values from options
    _selectedGender = _genderOptions.first;
    _selectedEducation = _pendidikanOptions.first;
    _selectedRegion = _regionOptions.first;
    _selectedRole = _roleOptions.first;
    _selectedIncome = _incomeOptions.first;

    // Initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    if (!mounted) return;
    final user = ref.read(currentUserProvider);
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _selectedGender = _genderToIndo[user.gender] ?? _selectedGender;
        _selectedEducation = _eduToIndo[user.educationLevel] ?? _selectedEducation;
        _selectedRegion = _regionToIndo[user.region] ?? _selectedRegion;
        _selectedRole = _roleToIndo[user.dailyRole] ?? _selectedRole;
        _selectedIncome = _incomeToIndo[user.incomeLevel] ?? _selectedIncome;
        _selectedDob = user.dateOfBirth;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    // Mapping back to DB values (English)
    final genderMap = {'Laki-laki': 'Male', 'Perempuan': 'Female'};
    final eduMap = {
      'SMA/SMK/Sederajat': 'High School',
      'Sarjana': 'Bachelor',
      'Magister': 'Master',
      'Doktor': 'PhD',
    };
    final regionMap = {
      'Afrika': 'Africa',
      'Asia': 'Asia',
      'Eropa': 'Europe',
      'Timur Tengah': 'Middle East',
      'Amerika Utara': 'North America',
      'Amerika Selatan': 'South America',
    };
    final roleMap = {
      'Pelajar/Mahasiswa': 'Student',
      'Karyawan Penuh waktu': 'Full-time',
      'Karyawan Paruh waktu': 'Part-time',
      'Pengurus rumah tangga': 'Caregiver',
      'Tidak bekerja/sedang mencari kerja': 'Unemployed',
    };
    final incomeMap = {
      'Rendah': 'Low',
      'Menengah Bawah': 'Lower-Mid',
      'Menengah Atas': 'Upper-Mid',
      'Tinggi': 'High',
    };

    final success = await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          gender: genderMap[_selectedGender],
          dateOfBirth: _selectedDob,
          region: regionMap[_selectedRegion],
          educationLevel: eduMap[_selectedEducation],
          dailyRole: roleMap[_selectedRole],
          incomeLevel: incomeMap[_selectedIncome],
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui'),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal memperbarui profil'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Data Diri',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('INFORMASI DASAR'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Jenis Kelamin',
                      value: _selectedGender,
                      items: _genderOptions,
                      onChanged: (v) => setState(() => _selectedGender = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('INFORMASI TAMBAHAN'),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Wilayah / Region',
                value: _selectedRegion,
                items: _regionOptions,
                onChanged: (v) => setState(() => _selectedRegion = v),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Tingkat Pendidikan',
                value: _selectedEducation,
                items: _pendidikanOptions,
                onChanged: (v) => setState(() => _selectedEducation = v),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Peran Harian',
                value: _selectedRole,
                items: _roleOptions,
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Tingkat Pendapatan',
                value: _selectedIncome,
                items: _incomeOptions,
                onChanged: (v) => setState(() => _selectedIncome = v),
              ),
              const SizedBox(height: 40),
              _buildSaveButton(isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textMuted.withValues(alpha: 0.6),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.4)),
            prefixIcon: Icon(icon, color: AppColors.teal, size: 20),
            filled: true,
            fillColor: AppColors.bgWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              items: items.map((String item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tgl Lahir',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.teal, size: 18),
                const SizedBox(width: 12),
                Text(
                  _selectedDob != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDob!)
                      : 'Pilih Tanggal',
                  style: TextStyle(
                    color: _selectedDob != null ? AppColors.textDark : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
      ),
    );
  }
}
