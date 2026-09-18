import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/colors.dart';
import '../providers/call_monitor_provider.dart';
import '../providers/history_provider.dart';
import '../providers/home_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/aegis_logo.dart';
import 'home/home_stat_cards.dart';
import 'home/recent_calls_section.dart';
import 'home/shield_hero.dart';
import 'home/simulate_call_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final history = ref.watch(historyProvider);
    final monitor = ref.watch(callMonitorProvider);

    final isProtected = home.detectionEnabled;
    final recentCalls = history.records.take(4).toList();

    return Scaffold(
      backgroundColor: bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bgSurfaceBorder),
                    ),
                    child: const Center(child: AegisLogo(size: 24)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VaakKavach',
                        style: GoogleFonts.plusJakartaSans(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'वाक्कवच • AI Communication Shield',
                        style: GoogleFonts.plusJakartaSans(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  if (monitor.isMonitoring)
                    GestureDetector(
                      onTap: () => context.push('/home/monitor'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentCyan),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: accentCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'MONITORING',
                              style: GoogleFonts.plusJakartaSans(
                                color: accentCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ShieldHero(
                isProtected: isProtected,
                onToggle: () =>
                    ref.read(homeProvider.notifier).toggleDetection(),
                onSimulate: () => SimulateCallSheet.show(context),
              ),
              const SizedBox(height: 18),
              HomeStatCards(
                todayScanned: history.todayScanned,
                blockedThreatsToday: history.blockedThreatsToday,
              ),
              const SizedBox(height: 24),
              RecentCallsSection(
                calls: recentCalls,
                onViewAll: () =>
                    ref.read(navigationProvider.notifier).setIndex(1),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
