// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aarti Sangrah';

  @override
  String get appTagline => 'Your complete collection of Hindu prayers and Aartis';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationDiscover => 'Discover';

  @override
  String get navigationMyPuja => 'My Puja';

  @override
  String get navigationCollection => 'Collection';

  @override
  String get navigationSettings => 'Settings';

  @override
  String navigationTabSemantics(Object label) {
    return '$label tab';
  }

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonDisabled => 'Disabled';

  @override
  String get commonTapToChange => 'Tap to change';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageGujarati => 'Gujarati';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingWelcomeTitle => 'Aarti Sangrah';

  @override
  String get onboardingWelcomeNativeTitle => 'आरती संग्रह';

  @override
  String get onboardingNameTitle => 'What should we\ncall you?';

  @override
  String get onboardingNameSubtitle => 'We\'ll personalize your daily greeting.';

  @override
  String get onboardingNameHint => 'Your name';

  @override
  String get onboardingScriptTitle => 'Choose your\npreferred script';

  @override
  String get onboardingScriptSubtitle => 'You can always change this later in Settings.';

  @override
  String get onboardingPreferredLanguage => 'Preferred language';

  @override
  String get scriptDevanagari => 'Devanagari';

  @override
  String get scriptEnglish => 'English';

  @override
  String get scriptGujarati => 'Gujarati';

  @override
  String get scriptRoman => 'Roman script';

  @override
  String get onboardingReminderTitle => 'Daily puja\nreminder';

  @override
  String get onboardingReminderSubtitle => 'We\'ll gently remind you at your preferred time.';

  @override
  String get onboardingDailyReminder => 'Daily Reminder';

  @override
  String onboardingReminderAt(Object time) {
    return 'Remind at $time';
  }

  @override
  String get onboardingReminderTime => 'Reminder Time';

  @override
  String get onboardingReminderBlessing => 'Start each day with a moment of devotion and inner peace.';

  @override
  String get homeGreetingInvocation => 'Jai Shri Krishna,';

  @override
  String get homeAartiOfTheDay => 'Aarti of the Day';

  @override
  String get homeRecentlyVisited => 'Recently Visited';

  @override
  String homeTodaySpecialLabel(Object dayName) {
    return '$dayName Special';
  }

  @override
  String homeTodaySubtitle(Object dayName, Object deityName) {
    return '$dayName · Begin with $deityName';
  }

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get deityShiva => 'Shiva';

  @override
  String get deityHanuman => 'Hanuman';

  @override
  String get deityGanesha => 'Ganesha';

  @override
  String get deityVishnu => 'Vishnu';

  @override
  String get deityDurga => 'Durga';

  @override
  String get deityRama => 'Rama';

  @override
  String get discoverBrowseByDeity => 'Browse by Deity';

  @override
  String get discoverFilterByFestival => 'Filter by Festival';

  @override
  String get discoverPopularAartis => 'Popular Aartis';

  @override
  String get discoverSearchPlaceholder => 'Search deity, Aarti, or festival…';

  @override
  String discoverResultCount(int count) {
    return '$count found';
  }

  @override
  String get discoverNoAartisFound => 'No Aartis found';

  @override
  String get discoverFestivalToday => 'TODAY';

  @override
  String discoverFestivalCountdown(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'IN $days DAYS',
      one: 'IN 1 DAY',
    );
    return '$_temp0';
  }

  @override
  String get aartiDetailAddBookmark => 'Add bookmark';

  @override
  String get aartiDetailRemoveBookmark => 'Remove bookmark';

  @override
  String aartiDetailVerseProgress(int current, int total) {
    return 'Verse $current of $total';
  }

  @override
  String get aartiDetailFocusMode => 'Focus Mode';

  @override
  String get aartiDetailMantraCounter => 'Mantra Counter';

  @override
  String get aartiDetailShare => 'Share';

  @override
  String get aartiDetailVerseDataComingSoon => 'Verse data coming soon for this Aarti.';

  @override
  String get aartiDetailFocusModeHeader => 'AARTI FOCUS MODE';

  @override
  String get aartiDetailContentLyrics => 'Lyrics';

  @override
  String get aartiDetailContentMeaning => 'Meaning';

  @override
  String get focusModeSettingsTitle => 'Reading Settings';

  @override
  String get focusModeSettingsReadingSurface => 'Reading Surface';

  @override
  String get focusModeSettingsTextSize => 'Text Size';

  @override
  String get aartiDetailFocusSettingsDescription => 'Adjust this focus session without changing your saved app settings.';

  @override
  String get aartiDetailFocusSettingsFooterWithNext => 'Reach the final verse to continue to the next aarti in your puja order. These changes stay only for this focus session.';

  @override
  String get aartiDetailFocusSettingsFooterReset => 'These changes stay only for this focus session and reset when you reopen focus mode.';

  @override
  String get aartiDetailShareTitle => 'Share Aarti';

  @override
  String get aartiDetailShareAsText => 'As Text';

  @override
  String get aartiDetailShareAsImage => 'As Image';

  @override
  String get focusModeOverlayNextAarti => 'Next Aarti';

  @override
  String focusModeOverlayNextNamed(Object title) {
    return 'Next: $title';
  }

  @override
  String get focusModeOverlayPreviousAarti => 'Previous Aarti';

  @override
  String focusModeOverlayPreviousNamed(Object title) {
    return 'Previous: $title';
  }

  @override
  String get focusModeOverlayCompleteSession => 'Complete Session';

  @override
  String get focusModeOverlayInstructionAdvance => 'Tap on or below the highlighted verse to advance';

  @override
  String get focusModeOverlayInstructionPreviousNext => 'Tap above for previous, tap on or below the highlighted verse for next';

  @override
  String get pujaFocusSessionHeader => 'PUJA FOCUS SESSION';

  @override
  String pujaSessionProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get pujaFocusSettingsDescription => 'Adjust how the current aarti is shown in focus session.';

  @override
  String get pujaFocusSettingsFooterContinue => 'Reach the final verse to continue to the next aarti in your puja order.';

  @override
  String get pujaFocusSettingsFooterComplete => 'Reach the final verse to finish this focus session.';

  @override
  String get settingsTitleLeading => 'App';

  @override
  String get settingsTitleTrailing => 'Settings';

  @override
  String get settingsSectionProfile => 'Profile';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionLanguageAndScript => 'Language & Script';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionPujaSession => 'Puja Session';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsSectionSupport => 'Support';

  @override
  String get settingsSectionDiagnostics => 'Diagnostics';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsDisplayName => 'Display Name';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsTextSize => 'Text Size';

  @override
  String get settingsAppLanguage => 'App Language';

  @override
  String get settingsPrimaryScript => 'Primary Script';

  @override
  String get settingsSecondaryScript => 'Secondary Script';

  @override
  String get settingsDailyPujaReminder => 'Daily Puja Reminder';

  @override
  String get settingsReminderTime => 'Reminder Time';

  @override
  String settingsReminderAt(Object time) {
    return 'Reminder at $time';
  }

  @override
  String get settingsAutoPlay => 'Auto-play';

  @override
  String get settingsAutoPlaySubtitle => 'Play next aarti in puja session';

  @override
  String get settingsCrossfadeDuration => 'Crossfade Duration';

  @override
  String settingsCrossfadeSubtitle(int seconds) {
    return '${seconds}s between aartis';
  }

  @override
  String get settingsUsageAnalytics => 'Usage Analytics';

  @override
  String get settingsAnalyticsEnabledSubtitle => 'Enabled for screen and feature insights';

  @override
  String get settingsAnalyticsDisabledSubtitle => 'Disabled on this device';

  @override
  String get settingsSendFeedback => 'Send Feedback';

  @override
  String get settingsFeedbackSubtitle => 'Report issues, suggest improvements, or share devotional feedback';

  @override
  String get settingsDevTools => 'DevTools';

  @override
  String get settingsDevToolsSubtitle => 'Open full diagnostics page';

  @override
  String get settingsActivityLog => 'Activity Log';

  @override
  String settingsActivityLogSubtitle(int count) {
    return '$count entries · View runtime activity';
  }

  @override
  String get settingsShareActivityLog => 'Share Activity Log';

  @override
  String get settingsShareActivityLogSubtitle => 'Export diagnostics file for troubleshooting';

  @override
  String get settingsContent => 'Content';

  @override
  String settingsAboutSubtitle(Object version) {
    return 'Version $version · Made with devotion';
  }

  @override
  String settingsContentSummary(int aartiCount, int festivalCount, Object syncStatus) {
    return '$aartiCount Aartis · $festivalCount Festivals ·\n$syncStatus';
  }

  @override
  String settingsContentLastRefresh(Object time) {
    return 'Last refresh $time';
  }

  @override
  String get settingsContentSourceRemote => 'Cached remote content';

  @override
  String get settingsContentSourceCached => 'Cached offline content';

  @override
  String get settingsContentSourceBundled => 'Bundled offline content';

  @override
  String get settingsContentRefreshSuccess => 'Content refreshed.';

  @override
  String get settingsContentRefreshFailed => 'Content refresh failed.';

  @override
  String settingsSecondaryScriptFallback(Object scriptLabel) {
    return '$scriptLabel · Fallback when app and primary scripts match';
  }

  @override
  String settingsSecondaryScriptUsage(Object scriptLabel) {
    return '$scriptLabel · Used in secondary reading mode and focus mode';
  }

  @override
  String get settingsNameDialogTitle => 'Your Name';

  @override
  String get settingsNameHint => 'Enter your name';

  @override
  String settingsActivityLogTitle(int count) {
    return 'Activity Log ($count)';
  }

  @override
  String get settingsActivityLogEmpty => 'No activity captured yet.';

  @override
  String get settingsActivityLogCleared => 'Activity log cleared';
}
