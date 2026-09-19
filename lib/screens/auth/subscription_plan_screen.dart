import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../constants/app_colors.dart';
import '../../models/subscription_plan.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../main_navigation_screen.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  final bool isOnboarding;

  const SubscriptionPlanScreen({super.key, this.isOnboarding = true});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  String? _selectedPlanId;
  bool _isProcessingPayment = false;
  late final Razorpay _razorpay;
  SubscriptionPlan? _pendingPlan;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadContent();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  SubscriptionPlan? _selectedPlan(List<SubscriptionPlan> plans) {
    if (plans.isEmpty) return null;
    return plans.firstWhere(
      (p) => p.id == _selectedPlanId,
      orElse: () => plans.first,
    );
  }

  Future<void> _confirmAndProceed(SubscriptionPlan selectedPlan) async {
    HapticFeedback.mediumImpact();
    final appState = context.read<AppState>();
    setState(() => _isProcessingPayment = true);

    try {
      final order = await appState.startCheckout(selectedPlan.id);
      _pendingPlan = selectedPlan;
      _razorpay.open({
        'key': order['keyId'],
        'order_id': order['orderId'],
        'amount': order['amount'],
        'currency': order['currency'],
        'name': 'NetLiv',
        'description': '${order['planName']} plan',
        'prefill': {'contact': appState.phoneNumber ?? ''},
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.message.contains('not configured')) {
        // Razorpay isn't set up yet — fall back to a local-only plan
        // switch so the rest of the app stays testable in the meantime.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payments are in demo mode (Razorpay not configured yet).')),
        );
        appState.setSelectedPlan(selectedPlan.id);
        _proceedAfterPayment(selectedPlan);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't reach the server. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final appState = context.read<AppState>();
    final plan = _pendingPlan;
    if (plan == null) return;

    try {
      await appState.verifyPayment(
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
      );
      appState.setSelectedPlan(plan.id);
      if (!mounted) return;
      _proceedAfterPayment(plan);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message ?? 'Please try again.'}')),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${response.walletName}...')),
    );
  }

  void _proceedAfterPayment(SubscriptionPlan selectedPlan) {
    if (!widget.isOnboarding) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to ${selectedPlan.name} plan')),
      );
      return;
    }

    // First time through onboarding: mark it done so it never shows again.
    unawaited(context.read<AppState>().completeOnboarding());

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
    final appState = context.watch<AppState>();
    final plans = appState.plans;

    if (plans.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: appState.isContentLoading
              ? const CircularProgressIndicator(color: AppColors.netflixRed)
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appState.contentError ?? 'No plans available right now.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => appState.loadContent(force: true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.netflixRed),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    final selectedPlan = _selectedPlan(plans)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle ambient brand glow backdrop
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.3, 0.6, 1.0],
                colors: [
                  Color(0xFF220508),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      if (!widget.isOnboarding) ...[
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
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      if (widget.isOnboarding)
                        Text(
                          'STEP 3 OF 3',
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
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFE0E0E0)],
                          ).createShader(bounds),
                          child: Text(
                            'Choose the plan\nthat\'s right for you',
                            style: GoogleFonts.inter(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.8,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No commitment — cancel anytime. All plans include unlimited streaming on our full library.',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 26),
                        ...plans.map((plan) => _buildPlanCard(plan, selectedPlan.id)),
                      ],
                    ),
                  ),
                ),

                // Bottom summary + CTA
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    border: const Border(
                      top: BorderSide(color: Color(0xFF1F1F1F), width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 24,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${selectedPlan.name} plan',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFB3B3B3),
                                ),
                              ),
                            ],
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: selectedPlan.price,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: ' /month',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8C8C8C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: AppColors.brandGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.netflixRed.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: _isProcessingPayment ? null : () => _confirmAndProceed(selectedPlan),
                              child: Center(
                                child: _isProcessingPayment
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                      )
                                    : Text(
                                        widget.isOnboarding ? 'Continue' : 'Confirm Plan Change',
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, String selectedPlanId) {
    final isSelected = selectedPlanId == plan.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedPlanId = plan.id);
        },
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.98,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF241012), Color(0xFF171212)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.netflixRed : const Color(0xFF2A2A2A),
                    width: isSelected ? 1.6 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.netflixRed.withOpacity(0.22),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: isSelected
                            ? AppColors.brandGradient
                            : const LinearGradient(
                                colors: [Color(0xFF2B2B2B), Color(0xFF1E1E1E)],
                              ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        plan.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  plan.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: plan.price,
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/mo',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF8C8C8C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentEmerald.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              plan.resolution,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentEmerald,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...plan.features.map(
                            (feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: isSelected
                                        ? AppColors.netflixRed
                                        : const Color(0xFF565656),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFFB3B3B3),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.netflixRed : const Color(0xFF565656),
                      size: 22,
                    ),
                  ],
                ),
              ),

              if (plan.isPopular)
                Positioned(
                  top: -10,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.netflixRed.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'MOST POPULAR',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
