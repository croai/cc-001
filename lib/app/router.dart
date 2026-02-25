import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/profile_screen.dart';
import '../features/events/presentation/event_list_screen.dart';
import '../features/events/presentation/event_detail_screen.dart';
import '../features/events/presentation/create_event_screen.dart';
import '../features/tickets/presentation/my_tickets_screen.dart';
import '../features/tickets/presentation/ticket_detail_screen.dart';
import '../features/tickets/presentation/purchase_flow_screen.dart';
import '../features/organizations/presentation/my_organizations_screen.dart';
import '../features/organizations/presentation/organization_detail_screen.dart';
import '../features/scanner/presentation/qr_scanner_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/events',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/events';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventListScreen(),
          ),
          GoRoute(
            path: '/my-tickets',
            builder: (context, state) => const MyTicketsScreen(),
          ),
          GoRoute(
            path: '/my-orgs',
            builder: (context, state) => const MyOrganizationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/event/:id',
        builder: (context, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/event/:id/purchase',
        builder: (context, state) =>
            PurchaseFlowScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ticket/:id',
        builder: (context, state) =>
            TicketDetailScreen(ticketId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/org/:id',
        builder: (context, state) => OrganizationDetailScreen(
          organizationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/scanner/:eventId',
        builder: (context, state) =>
            QrScannerScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: '/create-event',
        builder: (context, state) => const CreateEventScreen(),
      ),
    ],
  );
});

class HomeShell extends StatefulWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _routes = ['/events', '/my-tickets', '/my-orgs', '/profile'];

  @override
  Widget build(BuildContext context) {
    // Sync index with current route
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _routes.length; i++) {
      if (location == _routes[i]) {
        _currentIndex = i;
        break;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'My Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'My Orgs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
