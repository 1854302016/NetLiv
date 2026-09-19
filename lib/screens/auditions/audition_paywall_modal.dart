import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../state/app_state.dart';
import '../../services/audition_service.dart';

class AuditionPaywallModal extends StatefulWidget {
  final int? auditionId;
  final String? auditionTitle;
  final double fee;
  final VoidCallback onPaymentSuccess;

  const AuditionPaywallModal({
    super.key,
    this.auditionId,
    this.auditionTitle,
    required this.fee,
    required this.onPaymentSuccess,
  });

  @override
  State<AuditionPaywallModal> createState() => _AuditionPaywallModalState();
}

class _AuditionPaywallModalState extends State<AuditionPaywallModal> {
  late Razorpay _razorpay;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final token = appState.authToken;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to continue.';
      });
      return;
    }

    try {
      await AuditionService.verifyPayment(
        token,
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onPaymentSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('🎉 Audition Pass Activated! Opening Application Form...'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isLoading = false;
      _errorMessage = response.message ?? 'Payment cancelled or failed.';
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> _startCheckout() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final token = appState.authToken;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to purchase an audition pass.';
      });
      return;
    }

    try {
      final checkoutData = await AuditionService.checkout(
        token,
        auditionId: widget.auditionId,
      );

      final isTestMode = checkoutData['isTestMode'] == true;

      if (isTestMode) {
        // Direct sandbox simulated success
        await Future.delayed(const Duration(milliseconds: 600));
        await AuditionService.verifyPayment(
          token,
          orderId: checkoutData['orderId'],
          paymentId: 'pay_simulated_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (mounted) {
          Navigator.pop(context);
          widget.onPaymentSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF16A34A),
              content: Text('🎉 Audition Pass Activated! Opening Application Form...'),
            ),
          );
        }
        return;
      }

      final options = {
        'key': checkoutData['keyId'],
        'amount': checkoutData['amount'],
        'name': 'NetLiv Casting Hub',
        'order_id': checkoutData['orderId'],
        'description': widget.auditionTitle ?? 'Audition Registration Fee',
        'prefill': {
          'contact': appState.phoneNumber ?? '',
          'email': '',
        },
        'theme': {
          'color': '#E50914',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE50914), Color(0xFFB80710)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'OFFICIAL CASTING HUB',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            widget.auditionTitle ?? 'NetLiv Talent Audition Pass',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock your application form & showcase your talent to NetLiv Casting Directors.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Price Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE50914).withOpacity(0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Fee',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'One-time Audition Fee',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${widget.fee.toInt()}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF46D369),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Benefits List
          _buildBenefitItem('🎬 Direct review by NetLiv original directors & casting team'),
          _buildBenefitItem('📹 Upload your monologue video, script sample, or portfolio'),
          _buildBenefitItem('📞 Guaranteed real-time callback & audition status updates'),
          _buildBenefitItem('🌟 Chance to star in upcoming NetLiv Web Series & Movies'),
          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Pay Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _startCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_open, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Pay ₹${widget.fee.toInt()} & Apply Now',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Secured by Razorpay • 100% Verified Casting',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF46D369), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
