import 'package:go_router/go_router.dart';
import '../screens/main_shell.dart';
import '../screens/live_call_monitor_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainShell(),
      routes: [
        GoRoute(
          path: 'monitor',
          builder: (context, state) => const LiveCallMonitorScreen(),
        ),
      ],
    ),
  ],
);
