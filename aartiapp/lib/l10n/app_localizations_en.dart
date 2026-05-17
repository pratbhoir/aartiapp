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
  String get deityKrishna => 'Krishna';

  @override
  String get deityLakshmi => 'Lakshmi';

  @override
  String get deitySai => 'Sai';

  @override
  String get deityVishnu => 'Vishnu';

  @override
  String get deityDurga => 'Durga';

  @override
  String get deityRama => 'Rama';

  @override
  String get deityDetailBackToDiscover => 'Back to Discover';

  @override
  String get deityDetailTabAartis => 'Aartis';

  @override
  String get deityDetailTabShlokas => 'Shlokas';

  @override
  String get deityDetailTabChalisas => 'Chalisas';

  @override
  String deityDetailSummaryEmpty(Object deityLabel) {
    return 'No devotionals are available for $deityLabel yet.';
  }

  @override
  String deityDetailSummaryWithFestivals(int itemCount, int festivalCount, Object deityLabel) {
    return '$itemCount devotionals and $festivalCount related festivals for $deityLabel.';
  }

  @override
  String deityDetailSummaryDefault(int itemCount) {
    return '$itemCount devotionals gathered for prayer, reading, and listening.';
  }

  @override
  String get deityDetailTaglineGanesha => 'Remover of Obstacles · Lord of Beginnings';

  @override
  String get deityDetailTaglineShiva => 'The Auspicious One · Keeper of Stillness';

  @override
  String get deityDetailTaglineLakshmi => 'Goddess of Prosperity · Radiance and Grace';

  @override
  String get deityDetailTaglineDurga => 'Protector of Dharma · Fierce Compassion';

  @override
  String get deityDetailTaglineSai => 'Compassion, Surrender, and Grace';

  @override
  String get deityDetailTaglineHanuman => 'Strength, Devotion, and Fearlessness';

  @override
  String get deityDetailTaglineKrishna => 'Divine Love · Joy, Wisdom, and Playfulness';

  @override
  String get deityDetailTaglineRama => 'Maryada, Courage, and Devotion';

  @override
  String get deityDetailFallbackTagline => 'Daily prayer, listening, and reflection';

  @override
  String get deityDetailFallbackMantra => 'Sacred verses and daily devotion';

  @override
  String get deityDetailEveryDay => 'Every day';

  @override
  String get deityDetailDailyMantraLabel => 'Daily mantra';

  @override
  String deityDetailDevotionalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devotionals',
      one: '1 devotional',
    );
    return '$_temp0';
  }

  @override
  String get deityDetailMergedTypesNotice => 'This tab also includes stotras, mantras, chants, and other reading-first devotionals.';

  @override
  String get deityDetailPopularSection => 'Popular';

  @override
  String deityDetailPopularCaption(int count, Object deityLabel) {
    return '$count picks for $deityLabel';
  }

  @override
  String get deityDetailMoreAartis => 'More Aartis';

  @override
  String deityDetailMoreSection(Object sectionLabel) {
    return 'More $sectionLabel';
  }

  @override
  String get deityDetailMoreCaption => 'Continue your prayer with the full collection';

  @override
  String deityDetailEmptyTitle(Object tabLabel) {
    return 'No $tabLabel yet';
  }

  @override
  String deityDetailEmptyDescription(Object deityLabel) {
    return '$deityLabel does not have items in this section yet.';
  }

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
  String mantraCounterOverlayTapHint(int totalCount) {
    return 'Tap to count · $totalCount chants';
  }

  @override
  String get mantraCounterOverlayComplete => '🪷 Mala Complete · Jai Ho!';

  @override
  String get mantraCounterOverlayButtonTap => '॥ Tap to Chant ॥';

  @override
  String get mantraCounterOverlayButtonCompleted => '॥ Complete! ॥';

  @override
  String get mantraCounterOverlayReset => 'Reset counter';

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
  String get myPujaTitle => 'My Daily Puja';

  @override
  String myPujaSummary(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aartis',
      one: '1 aarti',
    );
    return '$_temp0 · Est. $minutes min';
  }

  @override
  String get myPujaPlayAartis => 'Play Aartis';

  @override
  String get myPujaReadAartis => 'Read Aartis';

  @override
  String get myPujaAutoPlayOn => 'Auto-play on';

  @override
  String get myPujaAutoPlayOff => 'Auto-play off';

  @override
  String get myPujaRepeatOn => 'Repeat on';

  @override
  String get myPujaRepeatOff => 'Repeat off';

  @override
  String myPujaCrossfadeChip(int seconds) {
    return 'Crossfade ${seconds}s';
  }

  @override
  String get myPujaEmptyTitle => 'Your daily puja is empty';

  @override
  String myPujaEmptyDescription(Object tabName) {
    return 'Bookmark Aartis from the $tabName tab\nto build your daily puja list.';
  }

  @override
  String get pujaSessionHeader => 'PUJA SESSION';

  @override
  String get pujaSessionRepeatChip => 'Repeat';

  @override
  String get pujaSessionSettingsTitle => 'Session Settings';

  @override
  String get pujaSessionAutoPlayNextLabel => 'Auto-play next';

  @override
  String get pujaSessionAutoPlayNextSubtitle => 'Play next aarti automatically';

  @override
  String get pujaSessionRepeatCurrentLabel => 'Repeat current';

  @override
  String get pujaSessionRepeatCurrentSubtitle => 'Loop the current aarti';

  @override
  String get pujaSessionCrossfadeLabel => 'Crossfade';

  @override
  String pujaSessionCrossfadeSubtitle(int seconds) {
    return '${seconds}s gap between aartis';
  }

  @override
  String pujaSessionCrossfadeOption(int seconds) {
    return '${seconds}s';
  }

  @override
  String get pujaSessionNoAudio => 'Audio unavailable for this aarti.';

  @override
  String get contributeAppBarTitle => 'My Collection';

  @override
  String get contributeSectionLabel => 'My Collection';

  @override
  String get contributeTitle => 'Personal Collection';

  @override
  String contributeSavedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved · Private to you',
      one: '1 saved · Private to you',
    );
    return '$_temp0';
  }

  @override
  String get contributeAddNewAarti => 'Add New Aarti';

  @override
  String get contributeEditingAarti => 'Editing Aarti';

  @override
  String get contributeDeityNameLabel => 'Deity Name';

  @override
  String get contributeDeityNameHint => 'e.g. Ganesha, Shiva, Lakshmi…';

  @override
  String get contributeAartiTitleEnglishLabel => 'Aarti Title (English)';

  @override
  String get contributeAartiTitleEnglishHint => 'e.g. Jai Ganesh Deva';

  @override
  String get contributeTitleDevanagariLabel => 'Title in Devanagari';

  @override
  String get contributeTitleDevanagariHint => 'e.g. जय गणेश देव';

  @override
  String get contributeLyricsDevanagariLabel => 'Lyrics (Devanagari)';

  @override
  String get contributeLyricsDevanagariHint => 'ॐ जय जगदीश हरे…\n\n(separate verses with a blank line)';

  @override
  String get contributeTransliterationLabel => 'Transliteration (Roman)';

  @override
  String get contributeTransliterationHint => 'Om Jai Jagdish Hare…\n\n(match verse structure above)';

  @override
  String get contributeGujaratiLabel => 'Gujarati Script (Optional)';

  @override
  String get contributeGujaratiHint => 'ૐ જય જગદીશ હરે…\n\n(match verse structure above)';

  @override
  String get contributeFestivalTagsLabel => 'Festival Tags (comma separated)';

  @override
  String get contributeFestivalTagsHint => 'e.g. Diwali, Navratri, Ganesh Chaturthi';

  @override
  String get contributeUpdateAarti => 'Update Aarti';

  @override
  String get contributeSaveToCollection => 'Save to My Collection';

  @override
  String get contributeEmptyTitle => 'No saved Aartis yet';

  @override
  String contributeEmptyDescription(Object ctaLabel) {
    return 'Tap \"$ctaLabel\" to create your\nfirst personal prayer.';
  }

  @override
  String get contributeSavedAartisHeading => 'Saved Aartis';

  @override
  String get contributeValidationDeityTitle => 'Please fill in at least Deity and Title.';

  @override
  String get contributeSuccessUpdated => 'Aarti updated! 🙏';

  @override
  String get contributeSuccessSaved => 'Aarti saved to your collection! 🙏';

  @override
  String get contributeDhruvaPad => 'Dhruva Pad';

  @override
  String contributeVerseLabel(int index) {
    return 'Verse $index';
  }

  @override
  String contributeVersesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '1 verse',
    );
    return '$_temp0';
  }

  @override
  String get feedbackScreenTitle => 'Send Feedback';

  @override
  String get feedbackGuidance => 'Use this form for devotional content corrections, app issues, and ideas that can improve the reading experience.';

  @override
  String get feedbackCategoryLabel => 'Category';

  @override
  String get feedbackTypeIncorrectLyrics => 'Incorrect Lyrics';

  @override
  String get feedbackTypeTranslationIssue => 'Translation Issue';

  @override
  String get feedbackTypeFeatureRequest => 'Feature Request';

  @override
  String get feedbackTypeBugReport => 'Bug Report';

  @override
  String get feedbackTypeGeneralFeedback => 'General Feedback';

  @override
  String get feedbackEmailLabel => 'Contact Email (optional)';

  @override
  String get feedbackEmailHint => 'name@example.com';

  @override
  String get feedbackMessageLabel => 'Message';

  @override
  String get feedbackMessageHint => 'Describe the issue, correction, or suggestion in detail.';

  @override
  String get feedbackSubmitButton => 'Send Feedback';

  @override
  String get feedbackValidationEmail => 'Enter a valid email address.';

  @override
  String get feedbackValidationMessageRequired => 'Please enter your feedback.';

  @override
  String feedbackValidationMessageTooLong(int maxLength) {
    return 'Feedback must stay under $maxLength characters.';
  }

  @override
  String get feedbackSuccessTitle => 'Feedback received';

  @override
  String get feedbackSuccessDescription => 'Thank you. Your note has been sent for review and will help improve the app and its devotional content.';

  @override
  String get feedbackSuccessResetButton => 'Send Another Response';

  @override
  String feedbackErrorServer(int statusCode) {
    return 'Feedback submission failed with status $statusCode.';
  }

  @override
  String get feedbackErrorTimeout => 'Feedback submission timed out. Please try again.';

  @override
  String get feedbackErrorGeneric => 'Unable to send feedback right now. Please try again.';

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
