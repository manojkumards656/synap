import 'biometric_snapshot.dart';

enum TransactionStatus {
  cleared,
  heldInEscrow,
}

class Transaction {
  final String id;
  final String recipientName;
  final String recipientIban;
  final double amount;
  final DateTime timestamp;
  final double cdiScore;
  final bool isCallActive;
  final TransactionStatus status;
  final BiometricSnapshot? snapshot;

  Transaction({
    required this.id,
    required this.recipientName,
    required this.recipientIban,
    required this.amount,
    required this.timestamp,
    required this.cdiScore,
    required this.isCallActive,
    required this.status,
    this.snapshot,
  });
}
