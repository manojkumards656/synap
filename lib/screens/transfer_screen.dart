import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../biometrics/biometric_service.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../telephony/call_state_service.dart';
import '../widgets/amount_field.dart';
import '../widgets/call_indicator.dart';
import '../widgets/cdi_gauge.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/recipient_field.dart';
import 'admin_screen.dart';
import 'escrow_hold_screen.dart';
import 'transaction_cleared_screen.dart';

enum ActiveField { recipient, amount }

class TransferScreen extends StatefulWidget {
  final String initialRecipient;
  final String initialAccount;

  const TransferScreen({
    super.key,
    this.initialRecipient = 'Priya Sharma (Granddaughter)',
    this.initialAccount = 'priya.sharma@okaxis',
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  ActiveField _selectedField = ActiveField.amount;
  late String _recipientName;
  late String _accountText;
  String _amountText = '50000';

  @override
  void initState() {
    super.initState();
    _recipientName = widget.initialRecipient;
    _accountText = widget.initialAccount;

    // Sync active call state to biometric service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final callService = context.read<CallStateService>();
      context.read<BiometricService>().updateCallState(callService.isCallActive);
    });
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_selectedField == ActiveField.recipient) {
        if (_accountText.length < 24) {
          _accountText += key;
        }
      } else {
        if (_amountText.length < 9) {
          if (_amountText == '0' && key != '.') {
            _amountText = key;
          } else {
            _amountText += key;
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_selectedField == ActiveField.recipient) {
        if (_accountText.isNotEmpty) {
          _accountText = _accountText.substring(0, _accountText.length - 1);
        }
      } else {
        if (_amountText.isNotEmpty) {
          _amountText = _amountText.substring(0, _amountText.length - 1);
          if (_amountText.isEmpty) _amountText = '0';
        }
      }
    });
  }

  void _executeTransfer() {
    final bioService = context.read<BiometricService>();
    final callService = context.read<CallStateService>();

    // Ensure call state is up-to-date
    bioService.updateCallState(callService.isCallActive);

    final amount = double.tryParse(_amountText) ?? 50000.0;
    final decision = bioService.evaluateTransaction(amount);

    final snapshot = bioService.currentSnapshot;
    final finalAccount = _accountText.isEmpty ? '918273645012@sbi' : _accountText;

    if (decision == TransactionDecision.escrow) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EscrowHoldScreen(
            amount: amount,
            recipientIban: finalAccount,
            recipientName: _recipientName,
            snapshot: snapshot,
            isCallActive: bioService.isCallActive,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionClearedScreen(
            amount: amount,
            recipientIban: finalAccount,
            recipientName: _recipientName,
            snapshot: snapshot,
            decision: decision,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bioService = context.watch<BiometricService>();
    final callService = context.watch<CallStateService>();

    // Keep call state synchronized
    if (bioService.isCallActive != callService.isCallActive) {
      bioService.updateCallState(callService.isCallActive);
    }

    final currentCDI = bioService.currentCDI;

    return Scaffold(
      backgroundColor: SynapTheme.background,
      appBar: AppBar(
        title: const Text('Send Money (INR)'),
        actions: [
          IconButton(
            tooltip: 'View Fraud SOC Analytics',
            icon: const Icon(Icons.admin_panel_settings_outlined, color: SynapTheme.primaryCyan),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminScreen()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: CallIndicator(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Scrollable Section: Input Fields, CDI Gauge, and Elderly-Friendly status
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    // Verified Recipient Box (Indian UPI / Bank Account)
                    RecipientField(
                      recipientName: _recipientName,
                      accountOrUpi: _accountText,
                      isSelected: _selectedField == ActiveField.recipient,
                      onTap: () => setState(() => _selectedField = ActiveField.recipient),
                    ),
                    const SizedBox(height: 12),
                    // Amount Input Box with verbal conversion (e.g. ₹50,000)
                    AmountField(
                      rawAmount: _amountText,
                      isSelected: _selectedField == ActiveField.amount,
                      onTap: () => setState(() => _selectedField = ActiveField.amount),
                    ),
                    const SizedBox(height: 10),

                    // CDI Gauge with clean link to SOC analytics
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: SynapTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: SynapTheme.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          CDIGauge(cdiValue: currentCDI),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminScreen()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.analytics_outlined, size: 14, color: SynapTheme.primaryCyan),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'View Full SOC Calculation & Math Breakdown →',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: SynapTheme.primaryCyan,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Pinned Section: Large, Senior-Friendly Numeric Keypad & Submit CTA
            Container(
              decoration: const BoxDecoration(
                color: SynapTheme.background,
                border: Border(
                  top: BorderSide(color: SynapTheme.surfaceBorder, width: 1.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumericKeypad(
                    onKeyPressed: _onKeyPressed,
                    onBackspace: _onBackspace,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentCDI >= CDIConstants.thresholdCritical &&
                                  bioService.isCallActive
                              ? SynapTheme.statusCritical
                              : SynapTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _executeTransfer,
                        icon: const Icon(Icons.lock_outline, size: 20),
                        label: Text(
                          'Pay ₹${_amountText.isEmpty ? "0" : _amountText} Securely',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
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
    );
  }
}
