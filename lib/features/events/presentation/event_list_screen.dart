import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/utils/seed_data.dart';
import '../../auth/presentation/auth_provider.dart';
import 'events_provider.dart';

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  int _selectedChip = 0;
  bool _isSeeding = false;

  final List<String> _filters = [
    'All',
    'Today',
    'This Week',
    'Conferences',
    'Meetups',
    'Workshops',
  ];

  Future<void> _seedData() async {
    setState(() => _isSeeding = true);
    try {
      await seedDemoEvents(FirebaseFirestore.instance);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Demo events created!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Seed failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(publishedEventsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discover',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search events...',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedChip == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedChip = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filters[index],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Events list
            Expanded(
              child: eventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events found',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for upcoming events',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(publishedEventsProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return EventCard(
                          event: event,
                          onTap: () => context.push('/event/${event.id}'),
                        );
                      },
                    ),
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: 260,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error: ${err.toString()}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(publishedEventsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Temporary seed FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _isSeeding ? null : _seedData,
        backgroundColor: AppColors.secondary,
        child: _isSeeding
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
