import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../main_navigation_screen.dart';

/// Authentic replica of the Netflix Sign-In Screen based on Image 4 reference.
/// Features clean dark input field, solid Netflix Red 'Continue' CTA button,
/// expandable 'Get Help' accordion, Google reCAPTCHA notice, and authentic footer.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _inputController =
      TextEditingController(text: 'alex.vance@netliv.io');
  final FocusNode _inputFocusNode = FocusNode();

  bool _isHelpExpanded = false;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'हिन्दी', 'Español'];

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _proceedToHome() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background subtle dark crimson gradient matching Image 4
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 0.7, 1.0],
                colors: [
                  Color(0xFF220508), // deep subtle wine
                  Color(0xFF140305),
                  Color(0xFF090909),
                  Colors.black,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header: NetLiv Wordmark & Back Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF1F1F1F),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (Navigator.of(context).canPop()) ...[
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Image.asset(
                            'assets/images/logo.png',
                            height: 34,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      // Skip to Guest shortcut in top right
                      TextButton(
                        onPressed: _proceedToHome,
                        child: Text(
                          'Skip to Browse',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Form & Footer Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Main Sign-In Card / Form Content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Headline (matches Image 4: "Enter your info to sign \n in")
                              Text(
                                'Enter your info to sign\nin',
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Subtitle: "Or get started with a new account."
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Starting registration process...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Or get started with a new account.',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: const Color(0xFFB3B3B3),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Input Field ("Email or mobile number")
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.netflixDarkInput,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _inputFocusNode.hasFocus
                                        ? Colors.white
                                        : AppColors.netflixInputBorder,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.centerLeft,
                                child: TextField(
                                  controller: _inputController,
                                  focusNode: _inputFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Email or mobile number',
                                    hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFF8C8C8C),
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Red "Continue" Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _proceedToHome,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.netflixRed,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    'Continue',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // "Get Help ∨" Expandable Section
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _isHelpExpanded = !_isHelpExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Get Help',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      AnimatedRotation(
                                        turns: _isHelpExpanded ? 0.5 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expandable Help Content
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 250),
                                crossFadeState: _isHelpExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: const SizedBox.shrink(),
                                secondChild: Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF333333),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildHelpItem(
                                        'Forgot password?',
                                        () => ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Password reset instructions sent!')),
                                        ),
                                      ),
                                      const Divider(color: Color(0xFF333333), height: 16),
                                      _buildHelpItem(
                                        'Forgot email or phone number?',
                                        () => ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Contact helpline or enter billing info')),
                                        ),
                                      ),
                                      const Divider(color: Color(0xFF333333), height: 16),
                                      _buildHelpItem(
                                        'Sign in with a sign-in code',
                                        () => ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Enter TV pairing code')),
                                        ),
                                      ),
                                      const Divider(color: Color(0xFF333333), height: 16),
                                      _buildHelpItem(
                                        'Instant Demo Access (Explore as Guest)',
                                        _proceedToHome,
                                        isHighlighted: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Google reCAPTCHA Notice (matches Image 4)
                              Text(
                                "This page is protected by Google reCAPTCHA to ensure you're not a bot. Learn more.",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF8C8C8C),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Authentic Netflix Footer (Matches Image 4 Bottom)
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, VoidCallback onTap, {bool isHighlighted = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                color: isHighlighted ? AppColors.netflixRed : const Color(0xFFB3B3B3),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isHighlighted ? AppColors.netflixRed : const Color(0xFF707070),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF0F0F0F),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Questions? Call 000-800-919-1743 (Toll-Free)"
          Text(
            'Questions? Call 000-800-919-1743 (Toll-Free)',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF8C8C8C),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),

          // 2-column footer links (matches Image 4)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterLink('FAQ'),
                    const SizedBox(height: 14),
                    _buildFooterLink('Terms of Use'),
                    const SizedBox(height: 14),
                    _buildFooterLink('Cookie Preferences'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterLink('Help Centre'),
                    const SizedBox(height: 14),
                    _buildFooterLink('Privacy'),
                    const SizedBox(height: 14),
                    _buildFooterLink('Corporate Information'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // Language Selector Dropdown
          Container(
            height: 38,
            width: 125,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF4A4A4A),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: const Color(0xFF1E1E1E),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 18,
                ),
                items: _languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.translate_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedLanguage = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $text...'),
            duration: const Duration(milliseconds: 700),
          ),
        );
      },
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12.5,
          color: const Color(0xFF8C8C8C),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF8C8C8C),
        ),
      ),
    );
  }
}
