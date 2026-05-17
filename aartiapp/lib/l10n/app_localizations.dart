import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aarti Sangrah'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your complete collection of Hindu prayers and Aartis'**
  String get appTagline;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navigationDiscover;

  /// No description provided for @navigationMyPuja.
  ///
  /// In en, this message translates to:
  /// **'My Puja'**
  String get navigationMyPuja;

  /// No description provided for @navigationCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get navigationCollection;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// Semantic label for a bottom navigation tab.
  ///
  /// In en, this message translates to:
  /// **'{label} tab'**
  String navigationTabSemantics(Object label);

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get commonDisabled;

  /// No description provided for @commonTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get commonTapToChange;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get languageGujarati;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Aarti Sangrah'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeNativeTitle.
  ///
  /// In en, this message translates to:
  /// **'आरती संग्रह'**
  String get onboardingWelcomeNativeTitle;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we\ncall you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll personalize your daily greeting.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingNameHint;

  /// No description provided for @onboardingScriptTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your\npreferred script'**
  String get onboardingScriptTitle;

  /// No description provided for @onboardingScriptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can always change this later in Settings.'**
  String get onboardingScriptSubtitle;

  /// No description provided for @onboardingPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get onboardingPreferredLanguage;

  /// No description provided for @scriptDevanagari.
  ///
  /// In en, this message translates to:
  /// **'Devanagari'**
  String get scriptDevanagari;

  /// No description provided for @scriptEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get scriptEnglish;

  /// No description provided for @scriptGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get scriptGujarati;

  /// No description provided for @scriptRoman.
  ///
  /// In en, this message translates to:
  /// **'Roman script'**
  String get scriptRoman;

  /// No description provided for @onboardingReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily puja\nreminder'**
  String get onboardingReminderTitle;

  /// No description provided for @onboardingReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll gently remind you at your preferred time.'**
  String get onboardingReminderSubtitle;

  /// No description provided for @onboardingDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get onboardingDailyReminder;

  /// No description provided for @onboardingReminderAt.
  ///
  /// In en, this message translates to:
  /// **'Remind at {time}'**
  String onboardingReminderAt(Object time);

  /// No description provided for @onboardingReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get onboardingReminderTime;

  /// No description provided for @onboardingReminderBlessing.
  ///
  /// In en, this message translates to:
  /// **'Start each day with a moment of devotion and inner peace.'**
  String get onboardingReminderBlessing;

  /// No description provided for @homeGreetingInvocation.
  ///
  /// In en, this message translates to:
  /// **'Jai Shri Krishna,'**
  String get homeGreetingInvocation;

  /// No description provided for @homeAartiOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Aarti of the Day'**
  String get homeAartiOfTheDay;

  /// No description provided for @homeRecentlyVisited.
  ///
  /// In en, this message translates to:
  /// **'Recently Visited'**
  String get homeRecentlyVisited;

  /// No description provided for @homeTodaySpecialLabel.
  ///
  /// In en, this message translates to:
  /// **'{dayName} Special'**
  String homeTodaySpecialLabel(Object dayName);

  /// No description provided for @homeTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{dayName} · Begin with {deityName}'**
  String homeTodaySubtitle(Object dayName, Object deityName);

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @deityShiva.
  ///
  /// In en, this message translates to:
  /// **'Shiva'**
  String get deityShiva;

  /// No description provided for @deityHanuman.
  ///
  /// In en, this message translates to:
  /// **'Hanuman'**
  String get deityHanuman;

  /// No description provided for @deityGanesha.
  ///
  /// In en, this message translates to:
  /// **'Ganesha'**
  String get deityGanesha;

  /// No description provided for @deityVishnu.
  ///
  /// In en, this message translates to:
  /// **'Vishnu'**
  String get deityVishnu;

  /// No description provided for @deityDurga.
  ///
  /// In en, this message translates to:
  /// **'Durga'**
  String get deityDurga;

  /// No description provided for @deityRama.
  ///
  /// In en, this message translates to:
  /// **'Rama'**
  String get deityRama;

  /// No description provided for @discoverBrowseByDeity.
  ///
  /// In en, this message translates to:
  /// **'Browse by Deity'**
  String get discoverBrowseByDeity;

  /// No description provided for @discoverFilterByFestival.
  ///
  /// In en, this message translates to:
  /// **'Filter by Festival'**
  String get discoverFilterByFestival;

  /// No description provided for @discoverPopularAartis.
  ///
  /// In en, this message translates to:
  /// **'Popular Aartis'**
  String get discoverPopularAartis;

  /// No description provided for @discoverSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search deity, Aarti, or festival…'**
  String get discoverSearchPlaceholder;

  /// No description provided for @discoverResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} found'**
  String discoverResultCount(int count);

  /// No description provided for @discoverNoAartisFound.
  ///
  /// In en, this message translates to:
  /// **'No Aartis found'**
  String get discoverNoAartisFound;

  /// No description provided for @discoverFestivalToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get discoverFestivalToday;

  /// No description provided for @discoverFestivalCountdown.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{IN 1 DAY} other{IN {days} DAYS}}'**
  String discoverFestivalCountdown(int days);

  /// No description provided for @aartiDetailAddBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get aartiDetailAddBookmark;

  /// No description provided for @aartiDetailRemoveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get aartiDetailRemoveBookmark;

  /// No description provided for @aartiDetailVerseProgress.
  ///
  /// In en, this message translates to:
  /// **'Verse {current} of {total}'**
  String aartiDetailVerseProgress(int current, int total);

  /// No description provided for @aartiDetailFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get aartiDetailFocusMode;

  /// No description provided for @aartiDetailMantraCounter.
  ///
  /// In en, this message translates to:
  /// **'Mantra Counter'**
  String get aartiDetailMantraCounter;

  /// No description provided for @aartiDetailShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get aartiDetailShare;

  /// No description provided for @aartiDetailVerseDataComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Verse data coming soon for this Aarti.'**
  String get aartiDetailVerseDataComingSoon;

  /// No description provided for @aartiDetailFocusModeHeader.
  ///
  /// In en, this message translates to:
  /// **'AARTI FOCUS MODE'**
  String get aartiDetailFocusModeHeader;

  /// No description provided for @aartiDetailContentLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get aartiDetailContentLyrics;

  /// No description provided for @aartiDetailContentMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get aartiDetailContentMeaning;

  /// No description provided for @focusModeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Settings'**
  String get focusModeSettingsTitle;

  /// No description provided for @focusModeSettingsReadingSurface.
  ///
  /// In en, this message translates to:
  /// **'Reading Surface'**
  String get focusModeSettingsReadingSurface;

  /// No description provided for @focusModeSettingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get focusModeSettingsTextSize;

  /// No description provided for @aartiDetailFocusSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust this focus session without changing your saved app settings.'**
  String get aartiDetailFocusSettingsDescription;

  /// No description provided for @aartiDetailFocusSettingsFooterWithNext.
  ///
  /// In en, this message translates to:
  /// **'Reach the final verse to continue to the next aarti in your puja order. These changes stay only for this focus session.'**
  String get aartiDetailFocusSettingsFooterWithNext;

  /// No description provided for @aartiDetailFocusSettingsFooterReset.
  ///
  /// In en, this message translates to:
  /// **'These changes stay only for this focus session and reset when you reopen focus mode.'**
  String get aartiDetailFocusSettingsFooterReset;

  /// No description provided for @aartiDetailShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Aarti'**
  String get aartiDetailShareTitle;

  /// No description provided for @aartiDetailShareAsText.
  ///
  /// In en, this message translates to:
  /// **'As Text'**
  String get aartiDetailShareAsText;

  /// No description provided for @aartiDetailShareAsImage.
  ///
  /// In en, this message translates to:
  /// **'As Image'**
  String get aartiDetailShareAsImage;

  /// No description provided for @focusModeOverlayNextAarti.
  ///
  /// In en, this message translates to:
  /// **'Next Aarti'**
  String get focusModeOverlayNextAarti;

  /// No description provided for @focusModeOverlayNextNamed.
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String focusModeOverlayNextNamed(Object title);

  /// No description provided for @focusModeOverlayPreviousAarti.
  ///
  /// In en, this message translates to:
  /// **'Previous Aarti'**
  String get focusModeOverlayPreviousAarti;

  /// No description provided for @focusModeOverlayPreviousNamed.
  ///
  /// In en, this message translates to:
  /// **'Previous: {title}'**
  String focusModeOverlayPreviousNamed(Object title);

  /// No description provided for @focusModeOverlayCompleteSession.
  ///
  /// In en, this message translates to:
  /// **'Complete Session'**
  String get focusModeOverlayCompleteSession;

  /// No description provided for @focusModeOverlayInstructionAdvance.
  ///
  /// In en, this message translates to:
  /// **'Tap on or below the highlighted verse to advance'**
  String get focusModeOverlayInstructionAdvance;

  /// No description provided for @focusModeOverlayInstructionPreviousNext.
  ///
  /// In en, this message translates to:
  /// **'Tap above for previous, tap on or below the highlighted verse for next'**
  String get focusModeOverlayInstructionPreviousNext;

  /// No description provided for @pujaFocusSessionHeader.
  ///
  /// In en, this message translates to:
  /// **'PUJA FOCUS SESSION'**
  String get pujaFocusSessionHeader;

  /// No description provided for @pujaSessionProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String pujaSessionProgress(int current, int total);

  /// No description provided for @pujaFocusSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust how the current aarti is shown in focus session.'**
  String get pujaFocusSettingsDescription;

  /// No description provided for @pujaFocusSettingsFooterContinue.
  ///
  /// In en, this message translates to:
  /// **'Reach the final verse to continue to the next aarti in your puja order.'**
  String get pujaFocusSettingsFooterContinue;

  /// No description provided for @pujaFocusSettingsFooterComplete.
  ///
  /// In en, this message translates to:
  /// **'Reach the final verse to finish this focus session.'**
  String get pujaFocusSettingsFooterComplete;

  /// No description provided for @settingsTitleLeading.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsTitleLeading;

  /// No description provided for @settingsTitleTrailing.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitleTrailing;

  /// No description provided for @settingsSectionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsSectionProfile;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionLanguageAndScript.
  ///
  /// In en, this message translates to:
  /// **'Language & Script'**
  String get settingsSectionLanguageAndScript;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionPujaSession.
  ///
  /// In en, this message translates to:
  /// **'Puja Session'**
  String get settingsSectionPujaSession;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSectionSupport;

  /// No description provided for @settingsSectionDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get settingsSectionDiagnostics;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get settingsDisplayName;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get settingsTextSize;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsAppLanguage;

  /// No description provided for @settingsPrimaryScript.
  ///
  /// In en, this message translates to:
  /// **'Primary Script'**
  String get settingsPrimaryScript;

  /// No description provided for @settingsSecondaryScript.
  ///
  /// In en, this message translates to:
  /// **'Secondary Script'**
  String get settingsSecondaryScript;

  /// No description provided for @settingsDailyPujaReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Puja Reminder'**
  String get settingsDailyPujaReminder;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get settingsReminderTime;

  /// No description provided for @settingsReminderAt.
  ///
  /// In en, this message translates to:
  /// **'Reminder at {time}'**
  String settingsReminderAt(Object time);

  /// No description provided for @settingsAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto-play'**
  String get settingsAutoPlay;

  /// No description provided for @settingsAutoPlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play next aarti in puja session'**
  String get settingsAutoPlaySubtitle;

  /// No description provided for @settingsCrossfadeDuration.
  ///
  /// In en, this message translates to:
  /// **'Crossfade Duration'**
  String get settingsCrossfadeDuration;

  /// No description provided for @settingsCrossfadeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s between aartis'**
  String settingsCrossfadeSubtitle(int seconds);

  /// No description provided for @settingsUsageAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics'**
  String get settingsUsageAnalytics;

  /// No description provided for @settingsAnalyticsEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enabled for screen and feature insights'**
  String get settingsAnalyticsEnabledSubtitle;

  /// No description provided for @settingsAnalyticsDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disabled on this device'**
  String get settingsAnalyticsDisabledSubtitle;

  /// No description provided for @settingsSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settingsSendFeedback;

  /// No description provided for @settingsFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report issues, suggest improvements, or share devotional feedback'**
  String get settingsFeedbackSubtitle;

  /// No description provided for @settingsDevTools.
  ///
  /// In en, this message translates to:
  /// **'DevTools'**
  String get settingsDevTools;

  /// No description provided for @settingsDevToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open full diagnostics page'**
  String get settingsDevToolsSubtitle;

  /// No description provided for @settingsActivityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get settingsActivityLog;

  /// No description provided for @settingsActivityLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} entries · View runtime activity'**
  String settingsActivityLogSubtitle(int count);

  /// No description provided for @settingsShareActivityLog.
  ///
  /// In en, this message translates to:
  /// **'Share Activity Log'**
  String get settingsShareActivityLog;

  /// No description provided for @settingsShareActivityLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export diagnostics file for troubleshooting'**
  String get settingsShareActivityLogSubtitle;

  /// No description provided for @settingsContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get settingsContent;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · Made with devotion'**
  String settingsAboutSubtitle(Object version);

  /// No description provided for @settingsContentSummary.
  ///
  /// In en, this message translates to:
  /// **'{aartiCount} Aartis · {festivalCount} Festivals ·\n{syncStatus}'**
  String settingsContentSummary(int aartiCount, int festivalCount, Object syncStatus);

  /// No description provided for @settingsContentLastRefresh.
  ///
  /// In en, this message translates to:
  /// **'Last refresh {time}'**
  String settingsContentLastRefresh(Object time);

  /// No description provided for @settingsContentSourceRemote.
  ///
  /// In en, this message translates to:
  /// **'Cached remote content'**
  String get settingsContentSourceRemote;

  /// No description provided for @settingsContentSourceCached.
  ///
  /// In en, this message translates to:
  /// **'Cached offline content'**
  String get settingsContentSourceCached;

  /// No description provided for @settingsContentSourceBundled.
  ///
  /// In en, this message translates to:
  /// **'Bundled offline content'**
  String get settingsContentSourceBundled;

  /// No description provided for @settingsContentRefreshSuccess.
  ///
  /// In en, this message translates to:
  /// **'Content refreshed.'**
  String get settingsContentRefreshSuccess;

  /// No description provided for @settingsContentRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Content refresh failed.'**
  String get settingsContentRefreshFailed;

  /// No description provided for @settingsSecondaryScriptFallback.
  ///
  /// In en, this message translates to:
  /// **'{scriptLabel} · Fallback when app and primary scripts match'**
  String settingsSecondaryScriptFallback(Object scriptLabel);

  /// No description provided for @settingsSecondaryScriptUsage.
  ///
  /// In en, this message translates to:
  /// **'{scriptLabel} · Used in secondary reading mode and focus mode'**
  String settingsSecondaryScriptUsage(Object scriptLabel);

  /// No description provided for @settingsNameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get settingsNameDialogTitle;

  /// No description provided for @settingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get settingsNameHint;

  /// No description provided for @settingsActivityLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Log ({count})'**
  String settingsActivityLogTitle(int count);

  /// No description provided for @settingsActivityLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity captured yet.'**
  String get settingsActivityLogEmpty;

  /// No description provided for @settingsActivityLogCleared.
  ///
  /// In en, this message translates to:
  /// **'Activity log cleared'**
  String get settingsActivityLogCleared;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'gu': return AppLocalizationsGu();
    case 'hi': return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
