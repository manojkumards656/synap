import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../biometrics/biometric_service.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../telephony/call_state_service.dart';
import '../widgets/amount_field.dart';
import '../widgets/call_indicator.dart';
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
    this.initialRecipient = '',
    this.initialAccount = '',
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late ActiveField _selectedField;
  late String _recipientName;
  late String _accountText;
  String _amountText = '';

  @override
  void initState() {
    super.initState();
    _recipientName = widget.initialRecipient;
    _accountText = widget.initialAccount;

    // Start with recipient field if empty, otherwise focus on amount
    _selectedField = _accountText.isEmpty ? ActiveField.recipient : ActiveField.amount;

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
        }
      }
    });
  }

  void _executeTransfer() {
    if (_amountText.isEmpty || (double.tryParse(_amountText) ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount to transfer.'),
          backgroundColor: SynapTheme.statusElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _selectedField = ActiveField.amount);
      return;
    }

    final bioService = context.read<BiometricService>();
    final callService = context.read<CallStateService>();

    // Ensure call state is up-to-date
    bioService.updateCallState(callService.isCallActive);

    final amount = double.tryParse(_amountText) ?? 0.0;
    final decision = bioService.evaluateTransaction(amount);

    final snapshot = bioService.currentSnapshot;
    final finalAccount = _accountText.isEmpty ? 'Direct Transfer Account' : _accountText;
    final finalRecipient = _recipientName.isEmpty ? 'Beneficiary' : _recipientName;

    if (decision == TransactionDecision.escrow) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EscrowHoldScreen(
            amount: amount,
            recipientIban: finalAccount,
            recipientName: finalRecipient,
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
            recipientName: finalRecipient,
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
    final displayAmount = _amountText.isEmpty ? '0' : _amountText;

    return Scaffold(
      backgroundColor: SynapTheme.background,
      appBar: AppBar(
        title: const Text('Send Money (₹)'),
        actions: [
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
          const Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: CallIndicator(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Clean User Input Area (No admin clutter!)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Recipient Field (Starts empty when tapping Make a Payment)
                    RecipientField(
                      recipientName: _recipientName,
                      accountOrUpi: _accountText,
                      isSelected: _selectedField == ActiveField.recipient,
                      onTap: () => setState(() => _selectedField = ActiveField.recipient),
                    ),
                    const SizedBox(height: 14),

                    // Amount Field (Starts empty with blinking cursor)
                    AmountField(
                      rawAmount: _amountText,
                      isSelected: _selectedField == ActiveField.amount,
                      onTap: () => setState(() => _selectedField = ActiveField.amount),
                    ),
                    const SizedBox(height: 14),

                    // Clean Security Note for Consumers (Reassuring, no jargon)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: SynapTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SynapTheme.surfaceBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline, size: 16, color: SynapTheme.statusSafe),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Protected by Synap Real-Time Scam Interception Rails',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: SynapTheme.textSecondary,
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

            // Bottom Pinned Section: Large Accessible Keypad & Action CTA
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
                        icon: const Icon(Icons.arrow_forward_rounded, size: 22),
                        label: Text(
                          _amountText.isEmpty ? 'Pay Securely (₹)' : 'Pay ₹$displayAmount Securely',
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
