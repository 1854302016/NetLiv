import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../main_navigation_screen.dart';
import 'content_language_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  /// Only populated outside production, until a real SMS gateway is wired up
  /// on the backend. Shown on-screen so the flow is testable without one.
  final String? debugOtp;
  const OtpVerificationScreen({super.key, required this.mobileNumber, this.debugOtp});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final int _otpLength = 6;
  bool _isSubmitting = false;
  bool _isResending = false;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  int _timerSeconds = 30;
  Timer? _timer;
  late String? _debugOtp;

  @override
  void initState() {
    super.initState();
    _debugOtp = widget.debugOtp;
    for (int i = 0; i < _otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    _startTimer();
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    try {
      final debugOtp = await context.read<AppState>().requestOtp(widget.mobileNumber);
      if (!mounted) return;
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      setState(() => _debugOtp = debugOtp);
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new OTP has been sent.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't reach the server. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startTimer() {
    setState(() => _timerSeconds = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Check if fully entered
    bool isComplete = _controllers.every((c) => c.text.isNotEmpty);
    if (isComplete) {
      // Auto verify could be placed here
    }
  }

  Future<void> _verifyAndProceed() async {
    bool isComplete = _controllers.every((c) => c.text.isNotEmpty);
    if (!isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP')),
      );
      return;
    }

    final otp = _controllers.map((c) => c.text).join();

    setState(() => _isSubmitting = true);
    try {
      final isNewUser = await context.read<AppState>().verifyOtp(otp);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      // Returning users who already finished language + plan selection once
      // go straight into the app instead of seeing onboarding again.
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => isNewUser
              ? const ContentLanguageScreen()
              : const MainNavigationScreen(),
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't reach the server. Please try again.")),
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
            // Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your OTP',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'We have sent a 6-digit code to\n${widget.mobileNumber}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFFB3B3B3),
                        height: 1.4,
                      ),
                    ),
                    if (_debugOtp != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Test mode — OTP is $_debugOtp (no SMS gateway configured yet)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.netflixRed,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_otpLength, (index) {
                        return Container(
                          width: 48,
                          height: 62,
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _focusNodes[index].hasFocus ? AppColors.netflixRed : const Color(0xFF333333),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              setState(() {}); // to update border color on focus
                              _onOtpChanged(val, index);
                            },
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Resend Timer
                    Center(
                      child: _timerSeconds > 0
                          ? Text(
                              'Resend code in 00:${_timerSeconds.toString().padLeft(2, '0')}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF8C8C8C),
                              ),
                            )
                          : TextButton(
                              onPressed: _isResending ? null : _resendOtp,
                              child: Text(
                                _isResending ? 'Sending...' : 'Resend OTP',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Verify Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _verifyAndProceed,
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
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Verify & Proceed',
                          style: GoogleFonts.inter(
                            fontSize: 16,
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
