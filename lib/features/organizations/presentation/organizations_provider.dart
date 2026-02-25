import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/organization_model.dart';

final userOrganizationsProvider = StreamProvider<List<OrganizationModel>>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('organizations')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => OrganizationModel.fromFirestore(doc))
            .toList(),
      );
});
