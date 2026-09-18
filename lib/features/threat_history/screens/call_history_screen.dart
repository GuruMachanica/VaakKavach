import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/colors.dart';
import '../models/risk_level.dart';
import '../providers/history_provider.dart';
import 'history/call_record_tile.dart';
import 'history/history_filter_dropdown.dart';
import 'history/history_metric_bar.dart';
import 'history/history_search_field.dart';

class CallHistoryScreen extends ConsumerStatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  ConsumerState<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends ConsumerState<CallHistoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final records = state.filteredRecords;

    if (_searchCtrl.text != state.searchQuery) {
      _searchCtrl.value = TextEditingValue(
        text: state.searchQuery,
        selection: TextSelection.collapsed(offset: state.searchQuery.length),
      );
    }

    final threatCount =
        state.records.where((r) => r.riskLevel == RiskLevel.danger).length;

    return Container(
      color: bgPrimary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Log',
                        style: GoogleFonts.plusJakartaSans(
                          color: textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'On-device verified call records',
                        style: GoogleFonts.plusJakartaSans(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  HistoryFilterDropdown(
                    current: state.filterPeriod,
                    onSelect: (p) =>
                        ref.read(historyProvider.notifier).setFilter(p),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: HistoryMetricBar(
                records: state.records,
                todayScanned: state.todayScanned,
                threatCount: threatCount,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: HistorySearchField(
                controller: _searchCtrl,
                onChanged: (q) =>
                    ref.read(historyProvider.notifier).setSearch(q),
              ),
            ),

            const SizedBox(height: 14),
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Text(
                        'No call logs match your filter',
                        style: GoogleFonts.plusJakartaSans(
                          color: textMuted,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 6,
                      ),
                      itemCount: records.length,
                      itemBuilder: (_, i) => CallRecordTile(record: records[i])
                          .animate(delay: Duration(milliseconds: i * 40))
                          .fadeIn(duration: 250.ms),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
