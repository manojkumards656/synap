import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../biometrics/biometric_service.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../telephony/call_state_service.dart';
import '../widgets/amount_field.dart';
import '../widgets/call_indicator.dart';
import '../widgets/cdi_gauge.dart';
import '../widgets/iban_field.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/telemetry_panel.dart';
import 'escrow_hold_screen.dart';
import 'transaction_cleared_screen.dart';

enum ActiveField { iban, amount }

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  ActiveField _selectedField = ActiveField.iban;
  String _ibanText = '';
  String _amountText = '50000';

  @override
  void initState() {
    super.initState();
    // Sync active call state to biometric service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final callService = context.read<CallStateService>();
      context.read<BiometricService>().updateCallState(callService.isCallActive);
    });
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_selectedField == ActiveField.iban) {
        if (_ibanText.length < 24) {
          _ibanText += key;
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
      if (_selectedField == ActiveField.iban) {
        if (_ibanText.isNotEmpty) {
          _ibanText = _ibanText.substring(0, _ibanText.length - 1);
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
    final finalIban = _ibanText.isEmpty ? 'GB29NWBK60161331926819' : _ibanText;

    if (decision == TransactionDecision.escrow) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EscrowHoldScreen(
            amount: amount,
            recipientIban: finalIban,
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
            recipientIban: finalIban,
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
      appBar: AppBar(
        title: const Text('Direct Transfer'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: CallIndicator(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Scrollable Section: Input Fields, CDI Gauge, Telemetry
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    // IBAN Input Box
                    IbanField(
                      text: _ibanText,
                      isSelected: _selectedField == ActiveField.iban,
                      onTap: () => setState(() => _selectedField = ActiveField.iban),
                    ),
                    const SizedBox(height: 10),
                    // Amount Input Box
                    AmountField(
                      rawAmount: _amountText,
                      isSelected: _selectedField == ActiveField.amount,
                      onTap: () => setState(() => _selectedField = ActiveField.amount),
                    ),
                    const SizedBox(height: 10),
                    // Real-time CDI Gauge
                    CDIGauge(cdiValue: currentCDI),
                    // Live Telemetry Panel
                    const TelemetryPanel(),
                  ],
                ),
              ),
            ),
            // Bottom Pinned Section: Custom Numeric Keypad & Submit CTA
            Container(
              decoration: const BoxDecoration(
                color: AegisTheme.background,
                border: Border(
                  top: BorderSide(color: AegisTheme.surfaceBorder, width: 1),
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentCDI >= CDIConstants.thresholdCritical &&
                                  bioService.isCallActive
                              ? AegisTheme.statusCritical
                              : AegisTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _executeTransfer,
                        child: Text(
                          'Authorize Transfer (₹${_amountText.isEmpty ? "0" : _amountText})',
                          style: const TextStyle(
                            fontSize: 16,
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
