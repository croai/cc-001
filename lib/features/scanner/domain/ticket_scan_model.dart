import 'package:cloud_firestore/cloud_firestore.dart';

class TicketScanModel {
  final String id;
  final String ticketId;
  final String scannedBy; // userId
  final String
  result; // admitted, rejected_already_used, rejected_invalid, rejected_wrong_event, rejected_cancelled
  final DateTime scannedAt;
  final String? deviceInfo;

  const TicketScanModel({
    required this.id,
    required this.ticketId,
    required this.scannedBy,
    required this.result,
    required this.scannedAt,
    this.deviceInfo,
  });

  factory TicketScanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TicketScanModel(
      id: doc.id,
      ticketId: data['ticketId'] as String? ?? '',
      scannedBy: data['scannedBy'] as String? ?? '',
      result: data['result'] as String? ?? '',
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deviceInfo: data['deviceInfo'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ticketId': ticketId,
      'scannedBy': scannedBy,
      'result': result,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'deviceInfo': deviceInfo,
    };
  }

  TicketScanModel copyWith({
    String? id,
    String? ticketId,
    String? scannedBy,
    String? result,
    DateTime? scannedAt,
    String? deviceInfo,
  }) {
    return TicketScanModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      scannedBy: scannedBy ?? this.scannedBy,
      result: result ?? this.result,
      scannedAt: scannedAt ?? this.scannedAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  bool get isAdmitted => result == 'admitted';
  bool get isRejected => result.startsWith('rejected_');
}
