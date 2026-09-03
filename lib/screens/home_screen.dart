import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../biometrics/biometric_service.dart';
import '../core/theme.dart';
import '../widgets/call_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AegisTheme.primaryBlue, AegisTheme.primaryCyan],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Synap Guardian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Behavioral Biometrics Active',
                  style: TextStyle(
                    fontSize: 10,
                    color: AegisTheme.statusSafe,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CallIndicator(compact: true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Manoj',
              style: TextStyle(
                fontSize: 14,
                color: AegisTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Account Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF162544),
                    Color(0xFF0F1A2E),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AegisTheme.primaryBlue.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AegisTheme.primaryBlue.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          fontSize: 13,
                          color: AegisTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AegisTheme.statusSafe.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user, size: 12, color: AegisTheme.statusSafe),
                            SizedBox(width: 4),
                            Text(
                              'PROTECTED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AegisTheme.statusSafe,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '₹4,85,230.00',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AegisTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Premier Savings •••• 4521',
                        style: TextStyle(
                          fontSize: 12,
                          color: AegisTheme.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'IFSC: SYNP0001289',
                        style: TextStyle(
                          fontSize: 11,
                          color: AegisTheme.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Primary Action Button: Send Money
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AegisTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // Reset session for fresh measurement
                  context.read<BiometricService>().resetSession();
                  Navigator.pushNamed(context, '/transfer');
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Transfer Funds (Live Demo)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Security Protection Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AegisTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AegisTheme.surfaceBorder),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.security_update_good,
                    color: AegisTheme.primaryCyan,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cognitive Duress Protection',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AegisTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Detects coercion and social engineering in real time via touch physics & telephony check.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AegisTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Recent Transactions
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AegisTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTxnTile(
              title: 'Amazon Online Retails',
              subtitle: 'Debit Card • Today, 14:22',
              amount: '-₹2,499.00',
              isCredit: false,
              icon: Icons.shopping_bag_outlined,
            ),
            _buildTxnTile(
              title: 'Salary Credit (TCS Global)',
              subtitle: 'NEFT • Yesterday',
              amount: '+₹75,000.00',
              isCredit: true,
              icon: Icons.account_balance_wallet_outlined,
            ),
            _buildTxnTile(
              title: 'Tata Power Mumbai',
              subtitle: 'Utility Bill • 2 days ago',
              amount: '-₹1,840.00',
              isCredit: false,
              icon: Icons.bolt_outlined,
            ),
            _buildTxnTile(
              title: 'Swiggy UPI Transfer',
              subtitle: 'UPI • 3 days ago',
              amount: '-₹345.00',
              isCredit: false,
              icon: Icons.fastfood_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTxnTile({
    required String title,
    required String subtitle,
    required String amount,
    required bool isCredit,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AegisTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AegisTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AegisTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AegisTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AegisTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AegisTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isCredit ? AegisTheme.statusSafe : AegisTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
