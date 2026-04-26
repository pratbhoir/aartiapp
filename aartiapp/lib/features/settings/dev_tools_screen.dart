import 'package:flutter/material.dart';

import '../../core/services/activity_log_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_aware_colors.dart';

/// Development diagnostics hub.
class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.borderSubtle),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.ink2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'DevTools',
                        style: AppTypography.serifBody(
                          size: 24,
                          color: context.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIAGNOSTICS',
                      style: AppTypography.label(
                        size: 10,
                        color: AppColors.ink3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DiagnosticsTile(
                      icon: Icons.fact_check_outlined,
                      title: 'Activity Log',
                      subtitle:
                          '${ActivityLogService.length} entries · View runtime activity',
                      onTap: () => _showActivityLog(context),
                    ),
                    const SizedBox(height: 12),
                    _DiagnosticsTile(
                      icon: Icons.ios_share_outlined,
                      title: 'Share Activity Log',
                      subtitle: 'Export diagnostics file for troubleshooting',
                      onTap: () async {
                        await ActivityLogService.share();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showActivityLog(BuildContext context) async {
    final entries = await ActivityLogService.getEntries();
    if (!context.mounted) return;

    final rows = List<Map<String, dynamic>>.from(entries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, modalSetState) {
            return Container(
              height: MediaQuery.of(modalContext).size.height * 0.78,
              decoration: BoxDecoration(
                color: modalContext.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.stone3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Activity Log (${rows.length})',
                            style: AppTypography.serifBody(
                              size: 18,
                              color: modalContext.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.ios_share_outlined,
                            size: 20,
                            color: AppColors.ink2,
                          ),
                          onPressed: () async {
                            await ActivityLogService.share();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.ink2,
                          ),
                          onPressed: () async {
                            await ActivityLogService.clear();
                            modalSetState(rows.clear);
                            if (!modalContext.mounted) return;
                            ScaffoldMessenger.of(modalContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Activity log cleared',
                                  style: AppTypography.body(
                                    size: 13,
                                    color: AppColors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.ink,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: rows.isEmpty
                        ? Center(
                            child: Text(
                              'No activity captured yet.',
                              style: AppTypography.body(
                                size: 14,
                                color: AppColors.ink3,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: rows.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) {
                              final row = rows[index];
                              return _ActivityLogEntryTile(entry: row);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DiagnosticsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DiagnosticsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.stone2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.ink2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body(
                      size: 14,
                      color: context.textPrimary,
                      weight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.body(size: 12, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

class _ActivityLogEntryTile extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _ActivityLogEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final level = (entry['level'] ?? 'info').toString();
    final tag = (entry['tag'] ?? 'General').toString();
    final message = (entry['msg'] ?? 'No message').toString();
    final stack = entry['stack']?.toString();
    final ts = _formatTimestamp(entry['ts']?.toString());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForLevel(level), size: 16, color: _colorForLevel(level)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$tag · ${level.toUpperCase()}',
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.ink2,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                ts,
                style: AppTypography.body(size: 11, color: AppColors.ink3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.body(
              size: 13,
              color: context.textPrimary,
              weight: FontWeight.w400,
            ),
          ),
          if (stack != null && stack.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              stack,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(size: 11, color: AppColors.ink3),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _iconForLevel(String level) {
    switch (level) {
      case 'error':
        return Icons.error_outline_rounded;
      case 'warn':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  static Color _colorForLevel(String level) {
    switch (level) {
      case 'error':
        return AppColors.saffronDark;
      case 'warn':
        return AppColors.gold;
      default:
        return AppColors.ink3;
    }
  }

  static String _formatTimestamp(String? ts) {
    if (ts == null || ts.trim().isEmpty) return '--';
    final parsed = DateTime.tryParse(ts);
    if (parsed == null) return ts;
    final local = parsed.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}