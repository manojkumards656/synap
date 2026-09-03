import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';

class CallStateService extends ChangeNotifier {
  bool _systemCallActive = false;
  bool? _simulatedCallOverride;
  StreamSubscription<PhoneState>? _subscription;
  bool _permissionGranted = false;
  String _statusMessage = 'Initializing telephony listener...';

  bool get isCallActive => _simulatedCallOverride ?? _systemCallActive;
  bool? get simulatedCallOverride => _simulatedCallOverride;
  bool get permissionGranted => _permissionGranted;
  String get statusMessage => _statusMessage;

  /// Initializes system phone state listener and requests runtime permission
  Future<void> initialize() async {
    try {
      final status = await Permission.phone.request();
      _permissionGranted = status.isGranted;

      if (_permissionGranted) {
        _statusMessage = 'Listening for incoming/active cellular calls';
        _listenToPhoneState();
      } else {
        _statusMessage = 'READ_PHONE_STATE permission not granted (simulation available)';
      }
    } catch (e) {
      _statusMessage = 'Telephony listener error: $e';
    }
    notifyListeners();
  }

  void _listenToPhoneState() {
    _subscription?.cancel();
    _subscription = PhoneState.stream.listen(
      (event) {
        final active = event.status == PhoneStateStatus.CALL_STARTED ||
            event.status == PhoneStateStatus.CALL_INCOMING;
        if (_systemCallActive != active) {
          _systemCallActive = active;
          _statusMessage = active ? 'Active cellular call detected' : 'Telephony idle';
          notifyListeners();
        }
      },
      onError: (err) {
        _statusMessage = 'Stream error: $err';
        notifyListeners();
      },
    );
  }

  /// Toggles manual simulation override.
  /// Extremely helpful for hackathon demos when presenting on an emulator or without a live caller.
  void setSimulatedCall(bool? override) {
    _simulatedCallOverride = override;
    _statusMessage = (override == true)
        ? 'Simulated Call Active [DEMO OVERRIDE]'
        : (override == false)
            ? 'Simulated Call Idle [DEMO OVERRIDE]'
            : 'Using Hardware Telephony Stream';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
