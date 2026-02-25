import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ticket_repository.dart';
import '../domain/ticket_model.dart';
import '../../auth/presentation/auth_provider.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

final userTicketsProvider = StreamProvider<List<TicketModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getUserTickets(user.uid);
});

final ticketDetailProvider = StreamProvider.family<TicketModel, String>((
  ref,
  ticketId,
) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicket(ticketId);
});
