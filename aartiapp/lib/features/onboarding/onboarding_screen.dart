import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_aware_colors.dart';
import '../../providers/app_providers.dart';

/// Multi-step onboarding flow shown on first app launch.
/// Steps: Welcome → Name → Script Preference → Notification Time → Done
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  final _nameCtrl = TextEditingController();
  int _selectedScript = 0; // 0=Devanagari, 1=Roman, 2=Gujarati
  String _selectedLang = 'hi'; // hi=Hindi, gu=Gujarati, en=English
  bool _enableNotifications = true;
  TimeOfDay _notifTime = const TimeOfDay(hour: 6, minute: 0);

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Save all preferences
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      ref.read(userNameProvider.notifier).setName(name);
    }
    ref.read(scriptModeProvider.notifier).setMode(_selectedScript);
    ref.read(preferredLanguageProvider.notifier).set(_selectedLang);

    if (_enableNotifications) {
      ref.read(notificationEnabledProvider.notifier).set(true);
      ref.read(notificationTimeProvider.notifier).set(_notifTime);
      await NotificationService.instance.init();
      final granted = await NotificationService.instance.requestPermission();
      if (granted) {
        await NotificationService.instance
            .scheduleDailyReminder(time: _notifTime);
      }
    }

    ref.read(onboardingCompletedProvider.notifier).complete();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: i <= _currentPage
                            ? AppColors.saffron
                            : AppColors.stone3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(),
                  _NamePage(
                    controller: _nameCtrl,
                  ),
                  _ScriptPage(
                    selectedScript: _selectedScript,
                    selectedLang: _selectedLang,
                    onScriptChanged: (s) =>
                        setState(() => _selectedScript = s),
                    onLangChanged: (l) =>
                        setState(() => _selectedLang = l),
                  ),
                  _NotificationPage(
                    enabled: _enableNotifications,
                    time: _notifTime,
                    onEnabledChanged: (v) =>
                        setState(() => _enableNotifications = v),
                    onTimeChanged: (t) =>
                        setState(() => _notifTime = t),
                  ),
                ],
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageCtrl.previousPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut),
                      child: Text('Back',
                          style: AppTextStyles.body(
                              size: 14, color: AppColors.ink3)),
                    ),
                  const Spacer(),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text('Skip',
                          style: AppTextStyles.body(
                              size: 14, color: AppColors.ink3)),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffron,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(120, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == 3 ? 'Get Started' : 'Continue',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: Welcome ────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.saffronGlow,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text('🙏', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Aarti Sangrah',
            style: AppTextStyles.displayLarge(context).copyWith(
              fontSize: 36,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your complete collection of\nHindu prayers and Aartis',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 16, color: AppColors.ink3),
          ),
          const SizedBox(height: 8),
          Text(
            'आरती संग्रह',
            style: AppTextStyles.devanagari(
                size: 22, color: AppColors.saffronDark),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: Name Input ─────────────────────────────────────────────────────

class _NamePage extends StatelessWidget {
  final TextEditingController controller;

  const _NamePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            'What should we\ncall you?',
            style: AppTextStyles.displayLarge(context).copyWith(
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll personalize your daily greeting.",
            style: AppTextStyles.body(size: 14, color: AppColors.ink3),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            autofocus: true,
            style: AppTextStyles.serifBody(
                size: 24, color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: AppTextStyles.serifBody(
                  size: 24, color: AppColors.ink3.withValues(alpha: 0.4)),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.stone3),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.saffron, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 3: Script + Language Preference ───────────────────────────────────

class _ScriptPage extends StatelessWidget {
  final int selectedScript;
  final String selectedLang;
  final ValueChanged<int> onScriptChanged;
  final ValueChanged<String> onLangChanged;

  const _ScriptPage({
    required this.selectedScript,
    required this.selectedLang,
    required this.onScriptChanged,
    required this.onLangChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            'Choose your\npreferred script',
            style: AppTextStyles.displayLarge(context).copyWith(
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can always change this later in Settings.',
            style: AppTextStyles.body(size: 14, color: AppColors.ink3),
          ),
          const SizedBox(height: 32),
          _ScriptOption(
            title: 'देवनागरी',
            subtitle: 'Devanagari',
            example: 'ॐ जय जगदीश हरे',
            isSelected: selectedScript == 0,
            onTap: () => onScriptChanged(0),
          ),
          const SizedBox(height: 12),
          _ScriptOption(
            title: 'Roman',
            subtitle: 'Transliteration',
            example: 'Om Jai Jagdish Hare',
            isSelected: selectedScript == 1,
            onTap: () => onScriptChanged(1),
          ),
          const SizedBox(height: 12),
          _ScriptOption(
            title: 'ગુજરાતી',
            subtitle: 'Gujarati',
            example: 'ૐ જય જગદીશ હરે',
            isSelected: selectedScript == 2,
            onTap: () => onScriptChanged(2),
          ),
          const SizedBox(height: 28),
          Text('PREFERRED LANGUAGE',
              style: AppTextStyles.label(size: 10, color: AppColors.ink3)),
          const SizedBox(height: 12),
          Row(
            children: [
              _LangChip(
                  label: 'हिन्दी',
                  code: 'hi',
                  isSelected: selectedLang == 'hi',
                  onTap: () => onLangChanged('hi')),
              const SizedBox(width: 10),
              _LangChip(
                  label: 'ગુજરાતી',
                  code: 'gu',
                  isSelected: selectedLang == 'gu',
                  onTap: () => onLangChanged('gu')),
              const SizedBox(width: 10),
              _LangChip(
                  label: 'English',
                  code: 'en',
                  isSelected: selectedLang == 'en',
                  onTap: () => onLangChanged('en')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScriptOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String example;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScriptOption({
    required this.title,
    required this.subtitle,
    required this.example,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffronGlow : context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.saffron : context.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.devanagari(
                          size: 18,
                          color: isSelected
                              ? AppColors.saffronDark
                              : context.textPrimary)),
                  Text(subtitle,
                      style: AppTextStyles.body(
                          size: 12, color: AppColors.ink3)),
                  const SizedBox(height: 4),
                  Text(example,
                      style: AppTextStyles.body(
                          size: 13,
                          color: isSelected
                              ? AppColors.saffronDark
                              : AppColors.ink3)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.saffron : AppColors.stone3,
                  width: 2,
                ),
                color:
                    isSelected ? AppColors.saffron : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffronGlow : context.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.saffron : context.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            size: 13,
            color: isSelected ? AppColors.saffronDark : AppColors.ink3,
            weight: isSelected ? FontWeight.w500 : FontWeight.w300,
          ),
        ),
      ),
    );
  }
}

// ─── Page 4: Notification Setup ─────────────────────────────────────────────

class _NotificationPage extends StatelessWidget {
  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const _NotificationPage({
    required this.enabled,
    required this.time,
    required this.onEnabledChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            'Daily puja\nreminder',
            style: AppTextStyles.displayLarge(context).copyWith(
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll gently remind you at your preferred time.",
            style: AppTextStyles.body(size: 14, color: AppColors.ink3),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.saffronGlow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      size: 20, color: AppColors.saffron),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Reminder',
                          style: AppTextStyles.body(
                              size: 15,
                              color: context.textPrimary,
                              weight: FontWeight.w400)),
                      Text(
                          enabled
                              ? 'Remind at ${time.format(context)}'
                              : 'Disabled',
                          style: AppTextStyles.body(
                              size: 12, color: AppColors.ink3)),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: enabled,
                  activeTrackColor: AppColors.saffron,
                  onChanged: onEnabledChanged,
                ),
              ],
            ),
          ),
          if (enabled) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null) {
                  onTimeChanged(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.saffronGlow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.schedule_outlined,
                          size: 20, color: AppColors.saffron),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reminder Time',
                              style: AppTextStyles.body(
                                  size: 15,
                                  color: context.textPrimary,
                                  weight: FontWeight.w400)),
                          Text('Tap to change',
                              style: AppTextStyles.body(
                                  size: 12, color: AppColors.ink3)),
                        ],
                      ),
                    ),
                    Text(
                      time.format(context),
                      style: AppTextStyles.serifBody(
                          size: 20, color: AppColors.saffron),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.saffronGlow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('🕉️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Start each day with a moment of devotion and inner peace.',
                    style: AppTextStyles.body(
                        size: 13, color: AppColors.saffronDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
