import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationMemberModel {
  final String id;
  final String organizationId;
  final String userId;
  final String role; // owner, admin, member
  final String? invitedBy;
  final DateTime joinedAt;

  const OrganizationMemberModel({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.role,
    this.invitedBy,
    required this.joinedAt,
  });

  factory OrganizationMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrganizationMemberModel(
      id: doc.id,
      organizationId: data['organizationId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      role: data['role'] as String? ?? 'member',
      invitedBy: data['invitedBy'] as String?,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'organizationId': organizationId,
      'userId': userId,
      'role': role,
      'invitedBy': invitedBy,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  OrganizationMemberModel copyWith({
    String? id,
    String? organizationId,
    String? userId,
    String? role,
    String? invitedBy,
    DateTime? joinedAt,
  }) {
    return OrganizationMemberModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      invitedBy: invitedBy ?? this.invitedBy,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin' || role == 'owner';
}
