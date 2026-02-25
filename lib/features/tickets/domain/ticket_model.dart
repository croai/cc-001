import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String orderId;
  final String eventId;
  final String ticketTypeId;
  final String userId;
  final String qrCode; // UUID v4, unique
  final String ticketNumber; // e.g. 'TKT-0001'
  final String attendeeName;
  final String attendeeEmail;
  final String status; // valid, used, cancelled
  final DateTime purchasedAt;
  final DateTime? usedAt;
  final DateTime? cancelledAt;

  const TicketModel({
    required this.id,
    required this.orderId,
    required this.eventId,
    required this.ticketTypeId,
    required this.userId,
    required this.qrCode,
    required this.ticketNumber,
    required this.attendeeName,
    required this.attendeeEmail,
    this.status = 'valid',
    required this.purchasedAt,
    this.usedAt,
    this.cancelledAt,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TicketModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      eventId: data['eventId'] as String? ?? '',
      ticketTypeId: data['ticketTypeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      qrCode: data['qrCode'] as String? ?? '',
      ticketNumber: data['ticketNumber'] as String? ?? '',
      attendeeName: data['attendeeName'] as String? ?? '',
      attendeeEmail: data['attendeeEmail'] as String? ?? '',
      status: data['status'] as String? ?? 'valid',
      purchasedAt:
          (data['purchasedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usedAt: (data['usedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'eventId': eventId,
      'ticketTypeId': ticketTypeId,
      'userId': userId,
      'qrCode': qrCode,
      'ticketNumber': ticketNumber,
      'attendeeName': attendeeName,
      'attendeeEmail': attendeeEmail,
      'status': status,
      'purchasedAt': Timestamp.fromDate(purchasedAt),
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }

  TicketModel copyWith({
    String? id,
    String? orderId,
    String? eventId,
    String? ticketTypeId,
    String? userId,
    String? qrCode,
    String? ticketNumber,
    String? attendeeName,
    String? attendeeEmail,
    String? status,
    DateTime? purchasedAt,
    DateTime? usedAt,
    DateTime? cancelledAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      eventId: eventId ?? this.eventId,
      ticketTypeId: ticketTypeId ?? this.ticketTypeId,
      userId: userId ?? this.userId,
      qrCode: qrCode ?? this.qrCode,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      attendeeName: attendeeName ?? this.attendeeName,
      attendeeEmail: attendeeEmail ?? this.attendeeEmail,
      status: status ?? this.status,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      usedAt: usedAt ?? this.usedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  bool get isValid => status == 'valid';
  bool get isUsed => status == 'used';
  bool get isCancelled => status == 'cancelled';
}
