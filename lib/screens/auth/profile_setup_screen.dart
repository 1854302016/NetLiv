import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import 'content_language_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  String _selectedGender = 'male';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _genders = [
    {
      'id': 'male',
      'label': 'Male',
      'icon': Icons.male_rounded,
    },
    {
      'id': 'female',
      'label': 'Female',
      'icon': Icons.female_rounded,
    },
    {
      'id': 'other',
      'label': 'Other',
      'icon': Icons.person_outline_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final currentName = appState.userName;
    final initialName = (currentName != null && !currentName.startsWith('User '))
        ? currentName
        : '';
    _nameController = TextEditingController(text: initialName);
    _ageController = TextEditingController(
      text: appState.userAge != null ? appState.userAge.toString() : '',
    );
    if (appState.userGender != null && appState.userGender!.isNotEmpty) {
      _selectedGender = appState.userGender!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitAndProceed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 18;

    setState(() => _isSubmitting = true);
    try {
      await context.read<AppState>().updateUserBasicDetails(
            name: name,
            gender: _selectedGender,
            age: age,
          );

      if (!mounted) return;
      HapticFeedback.mediumImpact();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ContentLanguageScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save details. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: NetLiv Wordmark & Step indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    'STEP 1 OF 3',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set up your profile',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us a bit about you to get personalized movie and series recommendations.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name Field
                      Text(
                        'FULL NAME',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFA3A3A3),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            color: const Color(0xFF666666),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF161616),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF888888),
                            size: 22,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF333333)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF333333)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.netflixRed,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Gender Selection
                      Text(
                        'GENDER',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFA3A3A3),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: _genders.map((g) {
                          final isSelected = _selectedGender == g['id'];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _selectedGender = g['id'] as String);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.netflixRed.withOpacity(0.15)
                                        : const Color(0xFF161616),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.netflixRed
                                          : const Color(0xFF333333),
                                      width: isSelected ? 1.8 : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        g['icon'] as IconData,
                                        color: isSelected ? Colors.white : const Color(0xFF888888),
                                        size: 24,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        g['label'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected ? Colors.white : const Color(0xFFA3A3A3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // Age Field
                      Text(
                        'AGE',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFA3A3A3),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 24',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            color: const Color(0xFF666666),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF161616),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.cake_outlined,
                            color: Color(0xFF888888),
                            size: 22,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF333333)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF333333)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.netflixRed,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your age';
                          }
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed < 5 || parsed > 120) {
                            return 'Please enter a valid age (5-120)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Quick Age selector chips
                      Wrap(
                        spacing: 8,
                        children: [18, 21, 25, 30, 35, 40].map((quickAge) {
                          return ActionChip(
                            label: Text(
                              '$quickAge yrs',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _ageController.text == quickAge.toString()
                                    ? Colors.white
                                    : const Color(0xFF999999),
                              ),
                            ),
                            backgroundColor: _ageController.text == quickAge.toString()
                                ? AppColors.netflixRed
                                : const Color(0xFF1A1A1A),
                            side: BorderSide(
                              color: _ageController.text == quickAge.toString()
                                  ? AppColors.netflixRed
                                  : const Color(0xFF333333),
                            ),
                            onPressed: () {
                              setState(() {
                                _ageController.text = quickAge.toString();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Continue Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF1F1F1F),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.netflixRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
