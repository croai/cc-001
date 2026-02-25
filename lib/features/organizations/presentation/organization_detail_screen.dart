import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class OrganizationDetailScreen extends StatelessWidget {
  final String organizationId;
  const OrganizationDetailScreen({super.key, required this.organizationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization')),
      body: Center(
        child: Text(
          'Organization: $organizationId — Coming Soon',
          style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
