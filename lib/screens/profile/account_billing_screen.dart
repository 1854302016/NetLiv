import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
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
              subtitle: 'Used for your last payment',
              trailing: 'Update',
            )
          else
            _buildTile(
              context,
              icon: Icons.credit_card_off_rounded,
              title: 'No payment method yet',
              subtitle: 'Added automatically after your first payment',
            ),
          const SizedBox(height: 28),

          Text('Billing History', style: AppTypography.titleMedium),
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
            (record) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.planName, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                        Text(record.date, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(record.amount, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                      Text(
                        record.status,
                        style: AppTypography.bodySmall.copyWith(
                          color: record.status == 'Paid' ? AppColors.accentEmerald : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
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
    return InkWell(
      onTap: trailing == null
          ? null
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment method management coming soon')),
              );
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
      ),
    );
  }
}
