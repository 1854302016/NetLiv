import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../models/billing_record.dart';
import '../../state/app_state.dart';
import '../auth/subscription_plan_screen.dart';

class AccountBillingScreen extends StatefulWidget {
  const AccountBillingScreen({super.key});

  @override
  State<AccountBillingScreen> createState() => _AccountBillingScreenState();
}

class _AccountBillingScreenState extends State<AccountBillingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadBilling();
    });
  }

  void _showInvoiceDetails(BuildContext context, BillingRecord record) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InvoiceBottomSheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final plans = appState.plans;
    final plan = plans.isEmpty
        ? null
        : plans.firstWhere(
            (p) => p.id == appState.selectedPlanId,
            orElse: () => plans[plans.length ~/ 2],
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Account & Billing', style: AppTypography.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Plan Card
          if (plan != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(plan.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${plan.name} Plan',
                          style: AppTypography.titleMedium.copyWith(color: Colors.white),
                        ),
                        Text(
                          '${plan.price}/month  •  ${plan.resolution}',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionPlanScreen(isOnboarding: false),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Change Plan'),
            ),
          ),
          const SizedBox(height: 28),

          Text('Payment Method', style: AppTypography.titleMedium),
          const SizedBox(height: 10),
          if (appState.paymentMethod != null)
            _buildTile(
              context,
              icon: Icons.credit_card_rounded,
              title: appState.paymentMethod!.displayTitle,
              subtitle: 'Used for your last payment via Razorpay',
              trailing: null,
            )
          else
            _buildTile(
              context,
              icon: Icons.credit_card_off_rounded,
              title: 'No payment method yet',
              subtitle: 'Added automatically after your first payment',
            ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoices & Payment History', style: AppTypography.titleMedium),
              if (appState.billingHistory.isNotEmpty)
                Text(
                  '${appState.billingHistory.length} Total',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (appState.billingLoaded && appState.billingHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                appState.isLoggedIn
                    ? 'No payments yet. Your invoices will show up here after your first successful payment.'
                    : 'Sign in to see your billing history.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ),
          ...appState.billingHistory.map(
            (record) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showInvoiceDetails(context, record),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: record.status == 'Paid'
                              ? AppColors.accentEmerald.withOpacity(0.15)
                              : AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          record.status == 'Paid'
                              ? Icons.receipt_long_rounded
                              : Icons.error_outline_rounded,
                          color: record.status == 'Paid'
                              ? AppColors.accentEmerald
                              : AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.planName,
                              style: AppTypography.titleMedium.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${record.date} • ${record.invoiceNumber}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            record.amount,
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                record.status,
                                style: AppTypography.bodySmall.copyWith(
                                  color: record.status == 'Paid'
                                      ? AppColors.accentEmerald
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                if (subtitle != null)
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          if (trailing != null)
            Text(trailing, style: AppTypography.chip.copyWith(color: AppColors.primaryLight)),
        ],
      ),
    );
  }
}

class _InvoiceBottomSheet extends StatelessWidget {
  final BillingRecord record;

  const _InvoiceBottomSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Invoice Header: Logo & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: record.status == 'Paid'
                          ? AppColors.accentEmerald.withOpacity(0.15)
                          : AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: record.status == 'Paid'
                            ? AppColors.accentEmerald.withOpacity(0.4)
                            : AppColors.error.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          record.status == 'Paid' ? Icons.check_circle : Icons.error,
                          color: record.status == 'Paid' ? AppColors.accentEmerald : AppColors.error,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.status.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: record.status == 'Paid' ? AppColors.accentEmerald : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'TAX INVOICE & PAYMENT RECEIPT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF262626)),
              const SizedBox(height: 12),

              // Invoice Info Grid
              _buildRow('Invoice Number', record.invoiceNumber, isBold: true),
              const SizedBox(height: 8),
              _buildRow('Payment Date', record.dateTime),
              const SizedBox(height: 8),
              if (record.customerName.isNotEmpty) ...[
                _buildRow('Billed To', record.customerName),
                const SizedBox(height: 8),
              ],
              if (record.customerPhone.isNotEmpty) ...[
                _buildRow('Mobile Number', record.customerPhone),
                const SizedBox(height: 8),
              ],
              _buildRow('Payment Gateway', 'Razorpay Secure'),
              const SizedBox(height: 8),
              _buildRow('Payment ID', record.paymentId, isMonospace: true),
              const SizedBox(height: 8),
              _buildRow('Order ID', record.orderId, isMonospace: true),
              const SizedBox(height: 8),
              _buildRow('Payment Method', record.paymentMethod),
              const SizedBox(height: 16),

              const Divider(color: Color(0xFF262626)),
              const SizedBox(height: 12),

              // Plan breakdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF202020),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.planName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          record.amount,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Valid: ${record.date} - ${record.validUntil}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          record.billingCycle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                  ),
                  Text(
                    record.amount,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Taxes (Inclusive GST)',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                  ),
                  Text(
                    '₹0.00',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFF262626)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount Paid',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    record.amount,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentEmerald,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.netflixRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

  Widget _buildRow(String title, String value, {bool isBold = false, bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: isMonospace
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE0E0E0),
                  )
                : GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                    color: Colors.white,
                  ),
          ),
        ),
      ],
    );
  }
}
