import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../state/app_state.dart';
import '../../models/audition_model.dart';
import '../../services/audition_service.dart';
import 'audition_application_form_screen.dart';
import 'audition_paywall_modal.dart';

class AuditionHubScreen extends StatefulWidget {
  const AuditionHubScreen({super.key});

  @override
  State<AuditionHubScreen> createState() => _AuditionHubScreenState();
}

class _AuditionHubScreenState extends State<AuditionHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AuditionCall> _auditions = [];
  List<AuditionSubmissionItem> _mySubmissions = [];
  AuditionFeeInfo? _feeInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final token = appState.authToken;

    try {
      final auditions = await AuditionService.fetchAuditions();
      AuditionFeeInfo? feeInfo;
      List<AuditionSubmissionItem> submissions = [];

      if (token != null) {
        feeInfo = await AuditionService.fetchFeeInfo(token);
        submissions = await AuditionService.fetchMySubmissions(token);
      }

      if (mounted) {
        setState(() {
          _auditions = auditions;
          _feeInfo = feeInfo;
          _mySubmissions = submissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onApplyPressed(AuditionCall? audition) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isLoggedIn) {
      _showAuditionQuickLoginModal(audition);
      return;
    }

    final fee = audition?.registrationFee ?? _feeInfo?.registrationFee ?? 199.0;
    final hasPass = appState.hasActiveSubscription || _feeInfo?.hasPaidPass == true || _feeInfo?.isVip == true;

    if (hasPass) {
      _openApplicationForm(audition);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => AuditionPaywallModal(
          auditionId: audition?.id,
          auditionTitle: audition?.title,
          fee: fee,
          onPaymentSuccess: () {
            _loadData();
            _openApplicationForm(audition);
          },
        ),
      );
    }
  }

  void _showAuditionQuickLoginModal(AuditionCall? audition) {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    bool otpSent = false;
    bool isSubmitting = false;
    String? debugOtp;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.stars_rounded, color: Color(0xFFE50914), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Audition Registration',
                              style: GoogleFonts.outfit(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Quick mobile verification to unlock audition pass (₹199)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (errorText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorText!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!otpSent) ...[
                    Text(
                      'Enter Mobile Number',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF222222),
                        hintText: '9876543210',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final phone = phoneController.text.trim();
                                if (phone.length < 10) {
                                  setModalState(() => errorText = 'Please enter a valid 10-digit mobile number');
                                  return;
                                }
                                setModalState(() {
                                  isSubmitting = true;
                                  errorText = null;
                                });
                                try {
                                  final appState = Provider.of<AppState>(context, listen: false);
                                  final code = await appState.requestOtp(phone);
                                  setModalState(() {
                                    otpSent = true;
                                    debugOtp = code;
                                    isSubmitting = false;
                                  });
                                } catch (e) {
                                  setModalState(() {
                                    errorText = e.toString();
                                    isSubmitting = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Send OTP & Proceed', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Enter 6-Digit OTP sent to ${phoneController.text}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    if (debugOtp != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          otpController.text = debugOtp!;
                          setModalState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '👉 Tap to auto-fill Test OTP: $debugOtp',
                            style: const TextStyle(color: Color(0xFFE50914), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF222222),
                        hintText: '------',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final otp = otpController.text.trim();
                                if (otp.length != 6) {
                                  setModalState(() => errorText = 'Please enter complete 6-digit OTP');
                                  return;
                                }
                                setModalState(() {
                                  isSubmitting = true;
                                  errorText = null;
                                });
                                try {
                                  final appState = Provider.of<AppState>(context, listen: false);
                                  await appState.verifyOtp(otp);
                                  if (!sheetContext.mounted) return;
                                  Navigator.of(sheetContext).pop();
                                  if (mounted) {
                                    await _loadData();
                                    _onApplyPressed(audition);
                                  }
                                } catch (e) {
                                  setModalState(() {
                                    errorText = e.toString();
                                    isSubmitting = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Verify & Unlock Audition Pass', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openApplicationForm(AuditionCall? audition) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuditionApplicationFormScreen(
          auditionCall: audition,
          onSubmitted: () {
            _loadData();
            _tabController.animateTo(1); // Switch to My Auditions tab
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('CASTING', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 8),
            Text(
              'Auditions & Talent Hub',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE50914),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
          tabs: [
            const Tab(text: '🎬 Open Casting Calls'),
            Tab(text: '📋 My Applications (${_mySubmissions.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCastingCallsTab(),
                _buildMySubmissionsTab(),
              ],
            ),
    );
  }

  // TAB 1: Open Casting Calls
  Widget _buildCastingCallsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFE50914),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE50914), Color(0xFF830006)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFE50914).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('⭐ NETLIV ORIGINAL PRODUCTIONS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Dreaming of the Big Screen?',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Apply now for upcoming web series, movies & music albums. Open for Actors, Writers, Directors & Musicians.',
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.85), fontSize: 12.5),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _onApplyPressed(null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Register for Talent Pool 🚀', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Open Listings
            Text('Active Casting Calls', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            if (_auditions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Text('No active casting calls at the moment.', style: GoogleFonts.outfit(color: Colors.white54)),
              )
            else
              ..._auditions.map((audition) => _buildAuditionCard(audition)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditionCard(AuditionCall audition) {
    final appState = Provider.of<AppState>(context, listen: false);
    final hasPass = appState.hasActiveSubscription || _feeInfo?.hasPaidPass == true || _feeInfo?.isVip == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (audition.bannerUrl.isNotEmpty)
            Image.network(
              audition.bannerUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(height: 140, color: const Color(0xFF2A2A2A), child: const Icon(Icons.movie, color: Colors.white24, size: 40)),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        audition.category.toUpperCase(),
                        style: GoogleFonts.outfit(color: const Color(0xFFE50914), fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      hasPass ? '✨ 100% FREE (VIP)' : 'Fee: ₹${audition.registrationFee.toInt()}',
                      style: GoogleFonts.outfit(
                        color: hasPass ? const Color(0xFFFFD700) : const Color(0xFF46D369),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  audition.title,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  audition.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 12),
                if (audition.rolesWanted.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: audition.rolesWanted
                        .take(3)
                        .map((role) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(6)),
                              child: Text(role, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => _onApplyPressed(audition),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      hasPass ? 'Apply for Free (VIP Access) 🎬' : 'Apply for this Audition 🎬',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
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

  // TAB 2: My Applications & Status Timeline
  Widget _buildMySubmissionsTab() {
    if (_mySubmissions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_turned_in_outlined, color: Colors.white24, size: 64),
              const SizedBox(height: 16),
              Text(
                'No Auditions Submitted Yet',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse open casting calls in the first tab and submit your audition monologue or script!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFE50914),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mySubmissions.length,
        itemBuilder: (context, index) {
          final sub = _mySubmissions[index];
          return _buildSubmissionStatusCard(sub);
        },
      ),
    );
  }

  Widget _buildSubmissionStatusCard(AuditionSubmissionItem sub) {
    Color statusColor = const Color(0xFF6B7280);
    if (sub.status == 'shortlisted') statusColor = const Color(0xFFF59E0B);
    if (sub.status == 'callback_scheduled') statusColor = const Color(0xFF0284C7);
    if (sub.status == 'selected') statusColor = const Color(0xFF16A34A);
    if (sub.status == 'rejected') statusColor = const Color(0xFFE50914);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  sub.statusBadge,
                  style: GoogleFonts.outfit(color: statusColor, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                sub.submittedAt,
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sub.auditionTitle,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Role: ${sub.roleCategory} ${sub.targetRole != null ? "• ${sub.targetRole}" : ""}',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),

          // Callback or Feedback Notice
          if (sub.callbackDate != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CALLBACK SCHEDULED', style: GoogleFonts.outfit(color: const Color(0xFF0284C7), fontSize: 10, fontWeight: FontWeight.w800)),
                        Text(sub.callbackDate!, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (sub.candidateFeedback != null && sub.candidateFeedback!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CASTING TEAM NOTE:', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(sub.candidateFeedback!, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
