import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _T {
  // Header gradient (dark navy)
  static const headerTop = Color(0xFF0A1628);
  static const headerMid = Color(0xFF0D1F3C);
  static const headerBottom = Color(0xFF0F2347);

  // Page background
  static const bgPage = Color(0xFFF4F6F9);

  // Dark card (input/dropdown area — matches Kuesioner card)
  static const bgCard = Color(0xFF162040);
  static const bgCardBorder = Color(0xFF1E2E52);
  static const bgInput = Color(0xFF1A2847);

  // Teal accent
  static const teal = Color(0xFF00C4B8);
  static const tealSoft = Color(0x1A00C4B8);
  static const tealDark = Color(0xFF00A89E);
  static const tealGrad1 = Color(0xFF00A89E);

  // Text
  static const txtPrimary = Color(0xFFFFFFFF);
  static const txtSecondary = Color(0xFF8B9FC0);
  static const txtMuted = Color(0xFF4D6180);
  static const txtHint = Color(0xFF4D6180);

  // Border
  static const border = Color(0xFF1E2E52);
  static const borderFocus = Color(0xFF00C4B8);

  // Error snackbar
  static const error = Color(0xFFE05555);

  // Radius
  static const r18 = Radius.circular(18);
  static const r16 = Radius.circular(16);
  static const r12 = Radius.circular(12);
  static const r10 = Radius.circular(10);

  // Text styles
  static const tsAppBarTitle = TextStyle(
    color: txtPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const tsLabel = TextStyle(
    color: txtSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const tsInput = TextStyle(
    color: txtPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static const tsHint = TextStyle(
    color: txtHint,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static const tsSection = TextStyle(
    color: Color(0xFF4D6180),
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
  static const tsChip = TextStyle(
    color: teal,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const tsUserName = TextStyle(
    color: txtPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
}

// ─────────────────────────────────────────────────────────────
//  WAVE CLIPPER
// ─────────────────────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start kiri atas
    path.lineTo(0, size.height - 35);

    // Curve U terbalik smooth
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 60,
      size.width,
      size.height - 35,
    );

    // Tutup kanan atas
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────
class EditProfilScreen extends ConsumerStatefulWidget {
  const EditProfilScreen({super.key});

  @override
  ConsumerState<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends ConsumerState<EditProfilScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late AnimationController _entranceAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String? _selectedGender;
  String? _selectedEducation;
  String? _selectedIncome;
  String? _selectedRegion;
  String? _selectedRole;
  DateTime? _selectedDob;

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
    _selectedGender = _genderOptions.first;
    _selectedEducation = _pendidikanOptions.first;
    _selectedRegion = _regionOptions.first;
    _selectedRole = _roleOptions.first;
    _selectedIncome = _incomeOptions.first;

    _entranceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entranceAnim, curve: Curves.easeOutCubic),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
      _entranceAnim.forward();
    });
  }

  void _initData() {
    if (!mounted) return;
    final user = ref.read(currentUserProvider);
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _selectedGender = _genderToIndo[user.gender] ?? _selectedGender;
        _selectedEducation =
            _eduToIndo[user.educationLevel] ?? _selectedEducation;
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
    _entranceAnim.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _T.teal,
            onPrimary: Colors.white,
            surface: _T.bgCard,
            onSurface: _T.txtPrimary,
          ),
          dialogBackgroundColor: _T.bgCard,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

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

    final success = await ref
        .read(authProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          gender: genderMap[_selectedGender],
          dateOfBirth: _selectedDob,
          region: regionMap[_selectedRegion],
          educationLevel: eduMap[_selectedEducation],
          dailyRole: roleMap[_selectedRole],
          incomeLevel: incomeMap[_selectedIncome],
        );

    if (!mounted) return;
    if (success) {
      _showSnack('Profil berhasil diperbarui', isSuccess: true);
      Navigator.pop(context);
    } else {
      _showSnack(
        ref.read(authProvider).errorMessage ?? 'Gagal memperbarui profil',
        isSuccess: false,
      );
    }
  }

  void _showSnack(String msg, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isSuccess ? _T.tealDark : _T.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String get _initials {
    final n = _nameController.text.trim();
    if (n.isEmpty) return 'A';
    final parts = n.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : n[0].toUpperCase();
  }

  // ─────────────── BUILD ───────────────────────
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: _T.bgPage,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Dark navy header with wave ──
                  _ProfileHeaderWave(
                    initials: _initials,
                    nameController: _nameController,
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── INFORMASI DASAR ──
                        const _SectionHeader(title: 'INFORMASI DASAR'),
                        const SizedBox(height: 10),

                        _DarkCard(
                          child: Column(
                            children: [
                              _FieldItem(
                                label: 'Nama Lengkap',
                                child: _AppTextField(
                                  controller: _nameController,
                                  hint: 'Masukkan nama lengkap',
                                  icon: Icons.person_outline_rounded,
                                  onChanged: (_) => setState(() {}),
                                  validator: (v) => v!.isEmpty
                                      ? 'Nama tidak boleh kosong'
                                      : null,
                                ),
                              ),
                              const _CardDivider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: _FieldItem(
                                      label: 'Jenis Kelamin',
                                      child: _AppDropdown(
                                        value: _selectedGender,
                                        items: _genderOptions,
                                        icon: Icons.wc_rounded,
                                        onChanged: (v) =>
                                            setState(() => _selectedGender = v),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 70,
                                    color: _T.border,
                                  ),
                                  Expanded(
                                    child: _FieldItem(
                                      label: 'Tgl Lahir',
                                      child: _AppDateField(
                                        dob: _selectedDob,
                                        onTap: _selectDate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── INFORMASI TAMBAHAN ──
                        const _SectionHeader(title: 'INFORMASI TAMBAHAN'),
                        const SizedBox(height: 10),

                        _DarkCard(
                          child: Column(
                            children: [
                              _FieldItem(
                                label: 'Wilayah / Region',
                                child: _AppDropdown(
                                  value: _selectedRegion,
                                  items: _regionOptions,
                                  icon: Icons.public_rounded,
                                  onChanged: (v) =>
                                      setState(() => _selectedRegion = v),
                                ),
                              ),
                              const _CardDivider(),
                              _FieldItem(
                                label: 'Tingkat Pendidikan',
                                child: _AppDropdown(
                                  value: _selectedEducation,
                                  items: _pendidikanOptions,
                                  icon: Icons.school_outlined,
                                  onChanged: (v) =>
                                      setState(() => _selectedEducation = v),
                                ),
                              ),
                              const _CardDivider(),
                              _FieldItem(
                                label: 'Peran Harian',
                                child: _AppDropdown(
                                  value: _selectedRole,
                                  items: _roleOptions,
                                  icon: Icons.work_outline_rounded,
                                  onChanged: (v) =>
                                      setState(() => _selectedRole = v),
                                ),
                              ),
                              const _CardDivider(),
                              _FieldItem(
                                label: 'Tingkat Pendapatan',
                                child: _AppDropdown(
                                  value: _selectedIncome,
                                  items: _incomeOptions,
                                  icon: Icons.bar_chart_rounded,
                                  onChanged: (v) =>
                                      setState(() => _selectedIncome = v),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Save button ──
                        _SaveButton(
                          isLoading: isLoading,
                          onTap: isLoading ? null : _save,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.all(_T.r10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      title: const Text('Edit Data Diri', style: _T.tsAppBarTitle),
      centerTitle: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PROFILE HEADER WITH WAVE
// ─────────────────────────────────────────────────────────────
class _ProfileHeaderWave extends StatelessWidget {
  final String initials;
  final TextEditingController nameController;

  const _ProfileHeaderWave({
    required this.initials,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final name = nameController.text.trim().isEmpty
        ? 'Pengguna Activa'
        : nameController.text.trim();

    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          topPadding + 24, // sebelumnya +70
          16,
          100,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_T.headerTop, _T.headerMid, _T.headerBottom],
          ),
        ),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_T.tealGrad1, Color(0xFF0066CC)],
                      ),
                      border: Border.all(
                        color: _T.teal.withValues(alpha: 0.40),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _T.teal.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(name, style: _T.tsUserName),

                  const SizedBox(height: 6),

                  // Badge chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _T.tealSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _T.teal.withValues(alpha: 0.30),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: _T.teal,
                          size: 12,
                        ),
                        SizedBox(width: 5),
                        Text('Digital Wellness Explorer', style: _T.tsChip),
                      ],
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

// ─────────────────────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _T.teal,
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: _T.tsSection),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DARK CARD
// ─────────────────────────────────────────────────────────────
class _DarkCard extends StatelessWidget {
  final Widget child;
  const _DarkCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: const BorderRadius.all(_T.r18),
        border: Border.all(color: _T.bgCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(_T.r18),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FIELD ITEM
// ─────────────────────────────────────────────────────────────
class _FieldItem extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldItem({required this.label, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _T.teal,
                ),
              ),
              const SizedBox(width: 6),
              Text(label, style: _T.tsLabel),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CARD DIVIDER
// ─────────────────────────────────────────────────────────────
class _CardDivider extends StatelessWidget {
  const _CardDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: _T.border);
}

// ─────────────────────────────────────────────────────────────
//  TEXT FIELD
// ─────────────────────────────────────────────────────────────
class _AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onChanged,
    this.validator,
  });

  @override
  State<_AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<_AppTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: _focused ? _T.bgInput : Colors.transparent,
        borderRadius: const BorderRadius.all(_T.r12),
        border: Border.all(
          color: _focused
              ? _T.borderFocus.withValues(alpha: 0.45)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: _T.tsInput,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: _T.tsHint,
            prefixIcon: Icon(
              widget.icon,
              color: _focused ? _T.teal : _T.txtMuted,
              size: 18,
            ),
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 10,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DROPDOWN
// ─────────────────────────────────────────────────────────────
class _AppDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final IconData icon;
  final void Function(String?) onChanged;

  const _AppDropdown({
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: _T.bgCard,
        borderRadius: const BorderRadius.all(_T.r16),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _T.txtMuted,
          size: 18,
        ),
        isDense: true,
        style: _T.tsInput,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: _T.tsInput,
                ),
              ),
            )
            .toList(),
        selectedItemBuilder: (ctx) => items
            .map(
              (item) => Row(
                children: [
                  Icon(icon, color: _T.teal, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: _T.tsInput,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DATE FIELD
// ─────────────────────────────────────────────────────────────
class _AppDateField extends StatelessWidget {
  final DateTime? dob;
  final VoidCallback onTap;
  const _AppDateField({required this.dob, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: _T.teal, size: 16),
            const SizedBox(width: 8),
            Text(
              dob != null
                  ? DateFormat('dd/MM/yyyy').format(dob!)
                  : 'Pilih tanggal',
              style: dob != null ? _T.tsInput : _T.tsHint,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SAVE BUTTON
// ─────────────────────────────────────────────────────────────
class _SaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  const _SaveButton({required this.isLoading, required this.onTap});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap?.call();
      },
      onTapCancel: () => _press.forward(),
      child: ScaleTransition(
        scale: _press,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _T.bgCard,
            border: Border.all(color: _T.bgCardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: _T.teal,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
