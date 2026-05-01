import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/activity_log_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_aware_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../shared/utils/aarti_language_resolver.dart';
import 'feedback_screen.dart';
import 'dev_tools_screen.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/aarti_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  final VoidCallback onOpenDrawer;
  const SettingsScreen({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textScaleProvider);
    final scriptMode = ref.watch(scriptModeProvider);
    final appLanguage = ref.watch(preferredLanguageProvider);
    final userName = ref.watch(userNameProvider);
    final contentSync = ref.watch(contentSyncProvider);
    final secondaryScriptMode =
        AartiLanguageResolver.resolveSecondaryScriptMode(
          scriptMode: scriptMode,
          appLanguageCode: appLanguage,
        );

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AartiAppBar(
              onMenuTap: onOpenDrawer,
              showMenu: false,
              showLogoTitle: true,
              title: 'Settings',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SETTINGS',
                    style: AppTypography.label(
                      size: 10,
                      color: context.textCaption,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.displayLarge(
                        context,
                      ).copyWith(fontSize: 34),
                      children: const [
                        TextSpan(text: 'App '),
                        TextSpan(
                          text: 'Settings',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.saffron,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- User Name ---
                _SectionHeader('Profile'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Display Name',
                  subtitle: userName,
                  onTap: () => _showNameDialog(context, ref, userName),
                ),
                const SizedBox(height: 24),

                // --- Theme ---
                _SectionHeader('Appearance'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: _themeModeLabel(themeMode),
                  trailing: _ThemeToggle(
                    mode: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setTheme(mode),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Text Scale ---
                _SettingsTile(
                  icon: Icons.text_fields_outlined,
                  title: 'Text Size',
                  subtitle: '${(textScale * 100).round()}%',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ScaleButton(
                        label: 'A-',
                        onTap: () =>
                            ref.read(textScaleProvider.notifier).decrease(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${(textScale * 100).round()}%',
                          style: AppTypography.body(
                            size: 13,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                      _ScaleButton(
                        label: 'A+',
                        onTap: () =>
                            ref.read(textScaleProvider.notifier).increase(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Script ---
                _SectionHeader('Language & Script'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.translate_outlined,
                  title: 'App Language',
                  subtitle: _appLanguageLabel(appLanguage),
                  trailing: _AppLanguageSelector(
                    languageCode: appLanguage,
                    onChanged: (languageCode) => ref
                        .read(preferredLanguageProvider.notifier)
                        .set(languageCode),
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Primary Script',
                  subtitle: _scriptModeLabel(scriptMode),
                  trailing: _ScriptModeSelector(
                    mode: scriptMode,
                    onChanged: (mode) =>
                        ref.read(scriptModeProvider.notifier).setMode(mode),
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.compare_arrows_outlined,
                  title: 'Secondary Script',
                  subtitle: _secondaryScriptSubtitle(
                    scriptMode: scriptMode,
                    secondaryScriptMode: secondaryScriptMode,
                    appLanguageCode: appLanguage,
                  ),
                ),
                const SizedBox(height: 24),

                // --- Notifications (v1.5) ---
                _SectionHeader('Notifications'),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final notifEnabled = ref.watch(notificationEnabledProvider);
                    final notifTime = ref.watch(notificationTimeProvider);
                    return Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          title: 'Daily Puja Reminder',
                          subtitle: notifEnabled
                              ? 'Reminder at ${notifTime.format(context)}'
                              : 'Disabled',
                          trailing: Switch.adaptive(
                            value: notifEnabled,
                            activeTrackColor: AppColors.saffron,
                            onChanged: (v) async {
                              if (v) {
                                await NotificationService.instance.init();
                                final granted = await NotificationService
                                    .instance
                                    .requestPermission();
                                if (granted) {
                                  ref
                                      .read(
                                        notificationEnabledProvider.notifier,
                                      )
                                      .set(true);
                                  await NotificationService.instance
                                      .scheduleDailyReminder(time: notifTime);
                                }
                              } else {
                                ref
                                    .read(notificationEnabledProvider.notifier)
                                    .set(false);
                                await NotificationService.instance.cancelAll();
                              }
                            },
                          ),
                        ),
                        if (notifEnabled) ...[
                          const SizedBox(height: 12),
                          _SettingsTile(
                            icon: Icons.schedule_outlined,
                            title: 'Reminder Time',
                            subtitle: notifTime.format(context),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: notifTime,
                              );
                              if (picked != null) {
                                ref
                                    .read(notificationTimeProvider.notifier)
                                    .set(picked);
                                await NotificationService.instance
                                    .scheduleDailyReminder(time: picked);
                              }
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // --- Puja Session (v1.5) ---
                _SectionHeader('Puja Session'),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final crossfade = ref.watch(crossfadeProvider);
                    final autoPlay = ref.watch(autoPlayProvider);
                    return Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.playlist_play_rounded,
                          title: 'Auto-play',
                          subtitle: 'Play next aarti in puja session',
                          trailing: Switch.adaptive(
                            value: autoPlay,
                            activeTrackColor: AppColors.saffron,
                            onChanged: (v) =>
                                ref.read(autoPlayProvider.notifier).set(v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsTile(
                          icon: Icons.tune_outlined,
                          title: 'Crossfade Duration',
                          subtitle: '${crossfade}s between aartis',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(4, (i) {
                              final isActive = crossfade == i;
                              return GestureDetector(
                                onTap: () =>
                                    ref.read(crossfadeProvider.notifier).set(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 32,
                                  height: 28,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? _accentSurfaceColor(context)
                                        : context.border,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isActive
                                          ? _accentFillColor(context)
                                          : context.borderSubtle,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i}s',
                                      style: AppTypography.body(
                                        size: 10,
                                        color: isActive
                                            ? _accentTextColor(context)
                                            : context.textCaption,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // --- Support ---
                _SectionHeader('Support'),
                const SizedBox(height: AppSpacing.md),
                _SettingsTile(
                  icon: Icons.rate_review_outlined,
                  title: 'Send Feedback',
                  subtitle:
                      'Report issues, suggest improvements, or share devotional feedback',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FeedbackScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- Diagnostics ---
                _SectionHeader('Diagnostics'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.developer_mode_outlined,
                  title: 'DevTools',
                  subtitle: 'Open full diagnostics page',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DevToolsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Activity Log',
                  subtitle:
                      '${ActivityLogService.length} entries · View runtime activity',
                  onTap: () => _showActivityLog(context),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.ios_share_outlined,
                  title: 'Share Activity Log',
                  subtitle: 'Export diagnostics file for troubleshooting',
                  onTap: () async {
                    await ActivityLogService.share();
                  },
                ),
                const SizedBox(height: 24),

                // --- About ---
                _SectionHeader('About'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Aarti Sangrah',
                  subtitle: 'Version 1.5.0 · Made with devotion',
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.storage_outlined,
                  title: 'Content',
                  subtitle: _contentSubtitle(contentSync),
                  trailing: contentSync.isRefreshing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _accentTextColor(context),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.sync_rounded,
                          size: 23,
                          color: AppColors.saffronDark,
                        ),
                  onTap: contentSync.isRefreshing
                      ? null
                      : () async {
                          await ref
                              .read(contentSyncProvider.notifier)
                              .refreshNow();
                          if (!context.mounted) {
                            return;
                          }

                          final latestState = ref.read(contentSyncProvider);
                          final hasError = latestState.lastError != null;
                          final message =
                              latestState.statusMessage ??
                              (hasError
                                  ? 'Content refresh failed.'
                                  : 'Content refreshed.');

                          if (hasError) {
                            SnackBarHelper.showError(context, message);
                          } else {
                            SnackBarHelper.showSuccess(context, message);
                          }
                        },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _scriptModeLabel(int mode) {
    return AartiLanguageResolver.scriptLabel(mode);
  }

  String _appLanguageLabel(String code) {
    return AartiLanguageResolver.appLanguageLabel(code);
  }

  String _secondaryScriptSubtitle({
    required int scriptMode,
    required int secondaryScriptMode,
    required String appLanguageCode,
  }) {
    final selectedScript = AartiLanguageResolver.scriptFromMode(scriptMode);
    final appLanguageScript = AartiLanguageResolver.preferredScriptForLanguage(
      AartiLanguageResolver.appLanguageFromCode(appLanguageCode),
    );
    final secondaryLabel = _scriptModeLabel(secondaryScriptMode);
    if (selectedScript == appLanguageScript) {
      return '$secondaryLabel · Fallback when app and primary scripts match';
    }
    return '$secondaryLabel · Used in secondary reading mode and focus mode';
  }

  String _contentSubtitle(ContentSyncState state) {
    final syncTime = _latestContentSync(state);
    final syncTimeLabel = syncTime == null
        ? '${_contentSourceLabel(state)}'
        : 'Last refresh ${_formatClock(syncTime)}';

    return '${state.aartiCount} Aartis · ${state.festivalCount} Festivals · \n$syncTimeLabel';
  }

  String _contentSourceLabel(ContentSyncState state) {
    final sources = <String>{state.aartiSource, state.festivalSource};
    if (sources.contains('remote')) {
      return 'Cached remote content';
    }
    if (sources.contains('cache')) {
      return 'Cached offline content';
    }
    return 'Bundled offline content';
  }

  DateTime? _latestContentSync(ContentSyncState state) {
    final timestamps = <DateTime>[
      if (state.aartiLastSync != null) state.aartiLastSync!,
      if (state.festivalLastSync != null) state.festivalLastSync!,
    ];
    if (timestamps.isEmpty) {
      return null;
    }

    timestamps.sort();
    return timestamps.last;
  }

  String _formatClock(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showNameDialog(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Your Name',
          style: AppTypography.serifBody(size: 18, color: context.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: AppTypography.body(size: 14, color: context.textCaption),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(userNameProvider.notifier).setName(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: modalContext.borderSubtle,
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
                          icon: Icon(
                            Icons.ios_share_outlined,
                            size: 20,
                            color: modalContext.textSecondary,
                          ),
                          onPressed: () async {
                            await ActivityLogService.share();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: modalContext.textSecondary,
                          ),
                          onPressed: () async {
                            await ActivityLogService.clear();
                            modalSetState(rows.clear);
                            if (!modalContext.mounted) return;
                            SnackBarHelper.showSuccess(
                              modalContext,
                              'Activity log cleared',
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
                                color: modalContext.textCaption,
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
              Icon(
                _iconForLevel(level),
                size: 16,
                color: _colorForLevel(context, level),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$tag · ${level.toUpperCase()}',
                  style: AppTypography.body(
                    size: 12,
                    color: context.textSecondary,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                ts,
                style: AppTypography.body(size: 11, color: context.textCaption),
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
              style: AppTypography.body(size: 11, color: context.textCaption),
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

  static Color _colorForLevel(BuildContext context, String level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (level) {
      case 'error':
        return isDark ? AppColors.saffronLight : AppColors.saffronDark;
      case 'warn':
        return AppColors.gold;
      default:
        return context.textCaption;
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.label(size: 10, color: context.textCaption),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
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
                color: context.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: context.textSecondary),
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
                    style: AppTypography.body(
                      size: 12,
                      color: context.textCaption,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, size: 18, color: context.textCaption),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeBtn(
            icon: Icons.brightness_auto_outlined,
            isActive: mode == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
          _ThemeBtn(
            icon: Icons.light_mode_outlined,
            isActive: mode == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
          _ThemeBtn(
            icon: Icons.dark_mode_outlined,
            isActive: mode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ThemeBtn({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? context.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? _accentFillColor(context) : context.textCaption,
        ),
      ),
    );
  }
}

class _ScaleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ScaleButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body(
              size: 12,
              color: context.textSecondary,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScriptModeSelector extends StatelessWidget {
  final int mode;
  final ValueChanged<int> onChanged;

  const _ScriptModeSelector({required this.mode, required this.onChanged});

  static const _labels = ['अ', 'EN', 'અ'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final isActive = mode == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? context.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.dark
                                ? 0.18
                                : 0.08,
                          ),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _labels[i],
                  style: AppTypography.body(
                    size: 14,
                    color: isActive
                        ? _accentFillColor(context)
                        : context.textCaption,
                    weight: isActive ? FontWeight.w500 : FontWeight.w300,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AppLanguageSelector extends StatelessWidget {
  final String languageCode;
  final ValueChanged<String> onChanged;

  const _AppLanguageSelector({
    required this.languageCode,
    required this.onChanged,
  });

  static const _codes = ['en', 'hi', 'gu'];
  static const _labels = ['EN', 'हि', 'ગુ'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_codes.length, (index) {
          final String code = _codes[index];
          final bool isActive = languageCode == code;
          return GestureDetector(
            onTap: () => onChanged(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? context.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.dark
                                ? 0.18
                                : 0.08,
                          ),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _labels[index],
                  style: AppTypography.body(
                    size: 14,
                    color: isActive
                        ? _accentFillColor(context)
                        : context.textCaption,
                    weight: isActive ? FontWeight.w500 : FontWeight.w300,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

Color _accentFillColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.saffronLight : AppColors.saffron;
}

Color _accentSurfaceColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? AppColors.saffron.withValues(alpha: 0.18)
      : AppColors.saffronGlow;
}

Color _accentTextColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.saffronLight : AppColors.saffronDark;
}
