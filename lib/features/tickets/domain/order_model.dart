import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String userId;
  final String eventId;
  final String orderNumber; // e.g. 'ORD-20250219-0001'
  final String status; // completed, cancelled, refunded
  final int totalAmount; // in cents
  final String currency;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.orderNumber,
    this.status = 'completed',
    required this.totalAmount,
    this.currency = 'EUR',
    required this.createdAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      eventId: data['eventId'] as String? ?? '',
      orderNumber: data['orderNumber'] as String? ?? '',
      status: data['status'] as String? ?? 'completed',
      totalAmount: data['totalAmount'] as int? ?? 0,
      currency: data['currency'] as String? ?? 'EUR',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'eventId': eventId,
      'orderNumber': orderNumber,
      'status': status,
      'totalAmount': totalAmount,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? orderNumber,
    String? status,
    int? totalAmount,
    String? currency,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  String get formattedTotal {
    if (totalAmount == 0) return 'Besplatno';
    final euros = totalAmount / 100;
    final formatter = NumberFormat('#,##0.00', 'hr');
    return '${formatter.format(euros)} $currency';
  }

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';
}
