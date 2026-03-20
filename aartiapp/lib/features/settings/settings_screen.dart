import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/aarti_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  final VoidCallback onOpenDrawer;
  const SettingsScreen({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textScaleProvider);
    final scriptMode = ref.watch(scriptModeProvider);
    final userName = ref.watch(userNameProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: AartiAppBar(onMenuTap: onOpenDrawer)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SETTINGS',
                      style:
                          AppTextStyles.label(size: 10, color: AppColors.ink3)),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.displayLarge(context)
                          .copyWith(fontSize: 34),
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
                          style: AppTextStyles.body(
                              size: 13, color: AppColors.ink),
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
                  title: 'Default Script',
                  subtitle:
                      scriptMode == 0 ? 'Devanagari' : 'Roman Transliteration',
                  trailing: Switch.adaptive(
                    value: scriptMode == 1,
                    activeTrackColor: AppColors.saffron,
                    onChanged: (v) => ref
                        .read(scriptModeProvider.notifier)
                        .setMode(v ? 1 : 0),
                  ),
                ),
                const SizedBox(height: 24),

                // --- About ---
                _SectionHeader('About'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Aarti Sangrah',
                  subtitle: 'Version 1.0.0 · Made with devotion',
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.storage_outlined,
                  title: 'Content',
                  subtitle: '12 Aartis · All bundled offline',
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

  void _showNameDialog(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Your Name',
            style: AppTextStyles.serifBody(size: 18, color: AppColors.ink)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: AppTextStyles.body(size: 14, color: AppColors.ink3),
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.label(size: 10, color: AppColors.ink3),
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stone2),
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
                  Text(title,
                      style: AppTextStyles.body(
                          size: 14,
                          color: AppColors.ink,
                          weight: FontWeight.w400)),
                  Text(subtitle,
                      style:
                          AppTextStyles.body(size: 12, color: AppColors.ink3)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              const Icon(Icons.chevron_right, size: 18, color: AppColors.ink3),
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
        color: AppColors.stone2,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? AppColors.saffron : AppColors.ink3,
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
          color: AppColors.stone2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body(
                size: 12, color: AppColors.ink, weight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
