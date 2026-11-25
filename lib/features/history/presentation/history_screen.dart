import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../fasting/application/fasting_scope.dart';
import '../../fasting/domain/fasting_stats.dart';
import '../../fasting/presentation/session_history_tile.dart';

enum _Range { all, week }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _Range _range = _Range.all;

  @override
  Widget build(BuildContext context) {
    final controller = FastingScope.of(context);
    final theme = Theme.of(context);
    final all = controller.sessions; // newest first
    final sessions = _range == _Range.week
        ? sessionsSince(all, startOfWeek(controller.now()))
        : all;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'History',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (sessions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${sessions.length} logged',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tap any completed session to inspect its details.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              SegmentedButton<_Range>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: _Range.all, label: Text('All')),
                  ButtonSegment(value: _Range.week, label: Text('This week')),
                ],
                selected: {_range},
                onSelectionChanged: (s) => setState(() => _range = s.first),
              ),
              const SizedBox(height: 22),
              if (sessions.isEmpty)
                EmptyState(
                  icon: Icons.history_rounded,
                  title: all.isEmpty
                      ? 'No sessions yet'
                      : 'No sessions this week',
                  message: all.isEmpty
                      ? 'Completed fasts will appear here.'
                      : 'Switch to All to see earlier sessions.',
                )
              else
                for (var i = 0; i < sessions.length; i++) ...[
                  if (i == 0 ||
                      !isSameDay(
                        sessions[i].startAt,
                        sessions[i - 1].startAt,
                      )) ...[
                    if (i != 0) const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formatDate(sessions[i].startAt, full: true),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SessionHistoryTile(session: sessions[i]),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
