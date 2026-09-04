import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../biometrics/biometric_service.dart';
import '../core/theme.dart';
import 'admin_screen.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SynapTheme.background,
      appBar: AppBar(
        backgroundColor: SynapTheme.background,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: SynapTheme.primaryBlue,
              child: const Text(
                'M',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Synap Pay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
                Text(
                  'Secured by Indian Banking Rails',
                  style: TextStyle(fontSize: 10, color: SynapTheme.statusSafe, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Discreet Admin Console Access (No UI clutter)
          IconButton(
            tooltip: 'Fraud SOC Admin Console',
            icon: const Icon(Icons.shield_outlined, color: SynapTheme.primaryCyan),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPay-style Search / Pay Any Bar
            GestureDetector(
              onTap: () => _startTransfer(context, '', ''),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: SynapTheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: SynapTheme.surfaceBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: SynapTheme.textSecondary, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pay friends, phone number, or UPI ID',
                        style: TextStyle(
                          fontSize: 14,
                          color: SynapTheme.textMuted,
                        ),
                      ),
                    ),
                    Icon(Icons.mic_none, color: SynapTheme.textSecondary, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Google Pay 4 Circular Quick Action Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: 'Scan any\nQR code',
                  onTap: () => _startTransfer(context, '', ''),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.contacts_outlined,
                  label: 'Pay\ncontacts',
                  onTap: () => _startTransfer(context, 'Priya Sharma (Granddaughter)', 'priya.sharma@okaxis'),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.account_balance_outlined,
                  label: 'Bank\ntransfer',
                  onTap: () => _startTransfer(context, '', ''),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.alternate_email,
                  label: 'Pay UPI\nID',
                  onTap: () => _startTransfer(context, '', ''),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // People Section (GPay Iconic Round Avatars)
            const Text(
              'People',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SynapTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPersonAvatar(
                    context,
                    name: 'Priya',
                    subtitle: 'Family',
                    color: Colors.purple,
                    onTap: () => _startTransfer(context, 'Priya Sharma (Granddaughter)', 'priya.sharma@okaxis'),
                  ),
                  _buildPersonAvatar(
                    context,
                    name: 'Ramesh',
                    subtitle: 'Uncle',
                    color: Colors.teal,
                    onTap: () => _startTransfer(context, 'Ramesh Kumar (Uncle)', 'ramesh.kumar@okhdfcbank'),
                  ),
                  _buildPersonAvatar(
                    context,
                    name: 'Dr. Verma',
                    subtitle: 'Clinic',
                    color: Colors.blueAccent,
                    onTap: () => _startTransfer(context, 'Dr. Anand Verma', 'dr.verma@upi'),
                  ),
                  _buildPersonAvatar(
                    context,
                    name: 'Govt Utility',
                    subtitle: 'Electricity',
                    color: Colors.orange,
                    onTap: () => _startTransfer(context, 'BESCOM Electric Supply', 'bescom.billpay@sbi'),
                  ),
                  _buildPersonAvatar(
                    context,
                    name: 'Rajesh',
                    subtitle: 'Friend',
                    color: Colors.indigo,
                    onTap: () => _startTransfer(context, 'Rajesh Malhotra', 'rajesh.m@okaxis'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Big, Elderly-Friendly Bank Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1B2435),
                    Color(0xFF131926),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: SynapTheme.surfaceBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance, size: 18, color: SynapTheme.primaryCyan),
                          SizedBox(width: 8),
                          Text(
                            'State Bank of India •••• 4521',
                            style: TextStyle(
                              fontSize: 13,
                              color: SynapTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: SynapTheme.statusSafe.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield, size: 12, color: SynapTheme.statusSafe),
                            SizedBox(width: 4),
                            Text(
                              'PROTECTED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: SynapTheme.statusSafe,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Available Bank Balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: SynapTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '₹ 4,85,230.00',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: SynapTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Four Lakh Eighty-Five Thousand Two Hundred Thirty Rupees',
                    style: TextStyle(
                      fontSize: 12,
                      color: SynapTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Big Clean Button: Starts transfer with EMPTY bank number & amount
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SynapTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _startTransfer(context, '', ''),
                icon: const Icon(Icons.send_rounded, size: 22),
                label: const Text(
                  'Make a Payment / Transfer (₹)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Elderly-Friendly Scam Protection Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SynapTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SynapTheme.surfaceBorder),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: SynapTheme.statusSafe,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Synap Scam & Coercion Guard',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: SynapTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'If someone orders you to transfer money while on a phone call, Synap automatically freezes the transfer for 15 minutes to keep your funds safe.',
                          style: TextStyle(
                            fontSize: 12,
                            color: SynapTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent Transactions Section
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SynapTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildTxnTile(
              title: 'Priya Sharma (Birthday Gift)',
              subtitle: 'UPI • Paid from SBI • Today, 11:20 AM',
              amount: '-₹5,000.00',
              isCredit: false,
              icon: Icons.person_outline,
            ),
            _buildTxnTile(
              title: 'Monthly Pension Credit',
              subtitle: 'NEFT • Direct Govt Deposit • Yesterday',
              amount: '+₹75,000.00',
              isCredit: true,
              icon: Icons.account_balance_outlined,
            ),
            _buildTxnTile(
              title: 'Tata Power Electricity Bill',
              subtitle: 'Utility • Automatic Clearing • 3 days ago',
              amount: '-₹1,840.00',
              isCredit: false,
              icon: Icons.bolt_outlined,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _startTransfer(BuildContext context, String recipientName, String accountOrUpi) {
    context.read<BiometricService>().resetSession();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferScreen(
          initialRecipient: recipientName,
          initialAccount: accountOrUpi,
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: SynapTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: SynapTheme.surfaceBorder, width: 1.2),
            ),
            child: Icon(icon, color: SynapTheme.primaryCyan, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SynapTheme.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonAvatar(
    BuildContext context, {
    required String name,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: 0.25),
              child: Text(
                name[0],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SynapTheme.textPrimary),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: SynapTheme.textMuted),
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
        color: SynapTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SynapTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SynapTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: SynapTheme.primaryCyan),
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
                    color: SynapTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: SynapTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isCredit ? SynapTheme.statusSafe : SynapTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
