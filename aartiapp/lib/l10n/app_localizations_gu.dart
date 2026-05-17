// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'આરતી સંગ્રહ';

  @override
  String get appTagline => 'હિંદુ પ્રાર્થનાઓ અને આરતીઓનો તમારો સંપૂર્ણ સંગ્રહ';

  @override
  String get navigationHome => 'હોમ';

  @override
  String get navigationDiscover => 'શોધ';

  @override
  String get navigationMyPuja => 'મારી પૂજા';

  @override
  String get navigationCollection => 'સંગ્રહ';

  @override
  String get navigationSettings => 'સેટિંગ્સ';

  @override
  String navigationTabSemantics(Object label) {
    return '$label ટૅબ';
  }

  @override
  String get commonBack => 'પાછળ';

  @override
  String get commonNext => 'આગળ';

  @override
  String get commonCancel => 'રદ કરો';

  @override
  String get commonSave => 'સાચવો';

  @override
  String get commonSkip => 'છોડો';

  @override
  String get commonContinue => 'આગળ વધો';

  @override
  String get commonDisabled => 'બંધ';

  @override
  String get commonTapToChange => 'બદલવા માટે ટૅપ કરો';

  @override
  String get languageEnglish => 'અંગ્રેજી';

  @override
  String get languageHindi => 'હિન્દી';

  @override
  String get languageGujarati => 'ગુજરાતી';

  @override
  String get onboardingGetStarted => 'શરૂ કરો';

  @override
  String get onboardingWelcomeTitle => 'આરતી સંગ્રહ';

  @override
  String get onboardingWelcomeNativeTitle => 'આરતી સંગ્રહ';

  @override
  String get onboardingNameTitle => 'અમે તમને\nશું કહીને બોલાવીએ?';

  @override
  String get onboardingNameSubtitle => 'અમે તમારા દૈનિક અભિવાદનને વ્યક્તિગત બનાવશું.';

  @override
  String get onboardingNameHint => 'તમારું નામ';

  @override
  String get onboardingScriptTitle => 'તમારી પસંદગીની\nલિપિ પસંદ કરો';

  @override
  String get onboardingScriptSubtitle => 'તમે આને પછી સેટિંગ્સમાં બદલી શકો છો.';

  @override
  String get onboardingPreferredLanguage => 'પસંદની ભાષા';

  @override
  String get scriptDevanagari => 'દેવનાગરી';

  @override
  String get scriptEnglish => 'અંગ્રેજી';

  @override
  String get scriptGujarati => 'ગુજરાતી';

  @override
  String get scriptRoman => 'રોમન લિપિ';

  @override
  String get onboardingReminderTitle => 'દૈનિક પૂજા\nયાદ અપાવનાર';

  @override
  String get onboardingReminderSubtitle => 'અમે તમને તમારા પસંદગીના સમયે સૌમ્ય સ્મરણ કરાવીશું.';

  @override
  String get onboardingDailyReminder => 'દૈનિક સ્મરણ';

  @override
  String onboardingReminderAt(Object time) {
    return '$timeે યાદ અપાવો';
  }

  @override
  String get onboardingReminderTime => 'સ્મરણ સમય';

  @override
  String get onboardingReminderBlessing => 'દરેક દિવસની શરૂઆત ભક્તિ અને અંતરની શાંતિના ક્ષણથી કરો.';

  @override
  String get homeGreetingInvocation => 'જય શ્રી કૃષ્ણ,';

  @override
  String get homeAartiOfTheDay => 'આજની આરતી';

  @override
  String get homeRecentlyVisited => 'હાલમાં જોવાયેલ';

  @override
  String homeTodaySpecialLabel(Object dayName) {
    return '$dayName વિશેષ';
  }

  @override
  String homeTodaySubtitle(Object dayName, Object deityName) {
    return '$dayName · $deityNameથી શરૂઆત કરો';
  }

  @override
  String get weekdayMonday => 'સોમવાર';

  @override
  String get weekdayTuesday => 'મંગળવાર';

  @override
  String get weekdayWednesday => 'બુધવાર';

  @override
  String get weekdayThursday => 'ગુરુવાર';

  @override
  String get weekdayFriday => 'શુક્રવાર';

  @override
  String get weekdaySaturday => 'શનિવાર';

  @override
  String get weekdaySunday => 'રવિવાર';

  @override
  String get deityShiva => 'શિવ';

  @override
  String get deityHanuman => 'હનુમાન';

  @override
  String get deityGanesha => 'ગણેશ';

  @override
  String get deityVishnu => 'વિષ્ણુ';

  @override
  String get deityDurga => 'દુર્ગા';

  @override
  String get deityRama => 'રામ';

  @override
  String get discoverBrowseByDeity => 'દેવતા પ્રમાણે જુઓ';

  @override
  String get discoverFilterByFestival => 'તહેવાર પ્રમાણે ફિલ્ટર કરો';

  @override
  String get discoverPopularAartis => 'લોકપ્રિય આરતીઓ';

  @override
  String get discoverSearchPlaceholder => 'દેવતા, આરતી અથવા તહેવાર શોધો…';

  @override
  String discoverResultCount(int count) {
    return '$count મળ્યાં';
  }

  @override
  String get discoverNoAartisFound => 'કોઈ આરતી મળી નથી';

  @override
  String get discoverFestivalToday => 'આજે';

  @override
  String discoverFestivalCountdown(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days દિવસમાં',
      one: '1 દિવસે',
    );
    return '$_temp0';
  }

  @override
  String get aartiDetailAddBookmark => 'બુકમાર્ક ઉમેરો';

  @override
  String get aartiDetailRemoveBookmark => 'બુકમાર્ક દૂર કરો';

  @override
  String aartiDetailVerseProgress(int current, int total) {
    return 'શ્લોક $current માંથી $total';
  }

  @override
  String get aartiDetailFocusMode => 'ધ્યાન મોડ';

  @override
  String get aartiDetailMantraCounter => 'મંત્ર કાઉન્ટર';

  @override
  String get aartiDetailShare => 'શેર કરો';

  @override
  String get aartiDetailVerseDataComingSoon => 'આ આરતી માટે શ્લોક સામગ્રી ટૂંક સમયમાં આવશે.';

  @override
  String get aartiDetailFocusModeHeader => 'આરતી ધ્યાન મોડ';

  @override
  String get aartiDetailContentLyrics => 'પાઠ';

  @override
  String get aartiDetailContentMeaning => 'અર્થ';

  @override
  String get focusModeSettingsTitle => 'વાંચન સેટિંગ્સ';

  @override
  String get focusModeSettingsReadingSurface => 'વાંચન સપાટી';

  @override
  String get focusModeSettingsTextSize => 'લખાણ કદ';

  @override
  String get aartiDetailFocusSettingsDescription => 'તમારી સાચવેલી એપ સેટિંગ્સ બદલીયા વગર આ ધ્યાન સત્રને સમાયોજિત કરો.';

  @override
  String get aartiDetailFocusSettingsFooterWithNext => 'તમારી પૂજા ક્રમની આગામી આરતી સુધી જવા માટે અંતિમ શ્લોક સુધી પહોંચો. આ ફેરફારો ફક્ત આ ધ્યાન સત્ર માટે જ રહેશે.';

  @override
  String get aartiDetailFocusSettingsFooterReset => 'આ ફેરફારો ફક્ત આ ધ્યાન સત્ર માટે જ રહેશે અને ધ્યાન મોડ ફરીથી ખોલો ત્યારે રીસેટ થશે.';

  @override
  String get aartiDetailShareTitle => 'આરતી શેર કરો';

  @override
  String get aartiDetailShareAsText => 'ટેક્સ્ટ તરીકે';

  @override
  String get aartiDetailShareAsImage => 'છબી તરીકે';

  @override
  String get focusModeOverlayNextAarti => 'આગળી આરતી';

  @override
  String focusModeOverlayNextNamed(Object title) {
    return 'આગળી: $title';
  }

  @override
  String get focusModeOverlayPreviousAarti => 'પાછલી આરતી';

  @override
  String focusModeOverlayPreviousNamed(Object title) {
    return 'પાછલી: $title';
  }

  @override
  String get focusModeOverlayCompleteSession => 'સત્ર પૂર્ણ કરો';

  @override
  String get focusModeOverlayInstructionAdvance => 'આગળ વધવા માટે હાઇલાઇટ કરેલી પંક્તિ પર અથવા તેની નીચે ટૅપ કરો';

  @override
  String get focusModeOverlayInstructionPreviousNext => 'પાછળ માટે ઉપર ટૅપ કરો, આગળ માટે હાઇલાઇટ કરેલી પંક્તિ પર અથવા તેની નીચે ટૅપ કરો';

  @override
  String get pujaFocusSessionHeader => 'પૂજા ધ્યાન સત્ર';

  @override
  String pujaSessionProgress(int current, int total) {
    return '$current માંથી $total';
  }

  @override
  String get pujaFocusSettingsDescription => 'ફોકસ સત્રમાં હાલની આરતી કેવી રીતે દેખાય છે તે સમાયોજિત કરો.';

  @override
  String get pujaFocusSettingsFooterContinue => 'આગામી આરતી સુધી જવા માટે અંતિમ શ્લોક સુધી પહોંચો.';

  @override
  String get pujaFocusSettingsFooterComplete => 'આ ફોકસ સત્ર પૂર્ણ કરવા માટે અંતિમ શ્લોક સુધી પહોંચો.';

  @override
  String get settingsTitleLeading => 'એપ';

  @override
  String get settingsTitleTrailing => 'સેટિંગ્સ';

  @override
  String get settingsSectionProfile => 'પ્રોફાઇલ';

  @override
  String get settingsSectionAppearance => 'દેખાવ';

  @override
  String get settingsSectionLanguageAndScript => 'ભાષા અને લિપિ';

  @override
  String get settingsSectionNotifications => 'સૂચનાઓ';

  @override
  String get settingsSectionPujaSession => 'પૂજા સત્ર';

  @override
  String get settingsSectionPrivacy => 'ગોપનીયતા';

  @override
  String get settingsSectionSupport => 'સહાય';

  @override
  String get settingsSectionDiagnostics => 'નિદાન';

  @override
  String get settingsSectionAbout => 'વિશે';

  @override
  String get settingsDisplayName => 'દર્શાવતું નામ';

  @override
  String get settingsTheme => 'થીમ';

  @override
  String get settingsThemeLight => 'લાઇટ';

  @override
  String get settingsThemeDark => 'ડાર્ક';

  @override
  String get settingsThemeSystem => 'સિસ્ટમ';

  @override
  String get settingsTextSize => 'લખાણનું કદ';

  @override
  String get settingsAppLanguage => 'એપ ભાષા';

  @override
  String get settingsPrimaryScript => 'મુખ્ય લિપિ';

  @override
  String get settingsSecondaryScript => 'દ્વિતીય લિપિ';

  @override
  String get settingsDailyPujaReminder => 'દૈનિક પૂજા સ્મરણ';

  @override
  String get settingsReminderTime => 'સ્મરણ સમય';

  @override
  String settingsReminderAt(Object time) {
    return '$timeએ સ્મરણ';
  }

  @override
  String get settingsAutoPlay => 'ઓટો-પ્લે';

  @override
  String get settingsAutoPlaySubtitle => 'પૂજા સત્રમાં આગળની આરતી આપમેળે ચલાવો';

  @override
  String get settingsCrossfadeDuration => 'ક્રોસફેડ અવધિ';

  @override
  String settingsCrossfadeSubtitle(int seconds) {
    return '$seconds સેકંડનું અંતર';
  }

  @override
  String get settingsUsageAnalytics => 'ઉપયોગ વિશ્લેષણ';

  @override
  String get settingsAnalyticsEnabledSubtitle => 'સ્ક્રીન અને ફીચર ઇન્સાઇટ્સ માટે સક્રિય';

  @override
  String get settingsAnalyticsDisabledSubtitle => 'આ ઉપકરણ પર બંધ';

  @override
  String get settingsSendFeedback => 'પ્રતિસાદ મોકલો';

  @override
  String get settingsFeedbackSubtitle => 'મુદ્દાઓ જણાવો, સુધારા સૂચવો અથવા ભક્તિમય પ્રતિસાદ શેર કરો';

  @override
  String get settingsDevTools => 'ડેવટૂલ્સ';

  @override
  String get settingsDevToolsSubtitle => 'પૂર્ણ નિદાન પાનું ખોલો';

  @override
  String get settingsActivityLog => 'ઍક્ટિવિટી લોગ';

  @override
  String settingsActivityLogSubtitle(int count) {
    return '$count નોંધો · રનટાઇમ પ્રવૃત્તિ જુઓ';
  }

  @override
  String get settingsShareActivityLog => 'ઍક્ટિવિટી લોગ શેર કરો';

  @override
  String get settingsShareActivityLogSubtitle => 'ટ્રબલશૂટિંગ માટે નિદાન ફાઇલ નિકાસ કરો';

  @override
  String get settingsContent => 'સામગ્રી';

  @override
  String settingsAboutSubtitle(Object version) {
    return 'આવૃત્તિ $version · ભક્તિથી બનાવેલ';
  }

  @override
  String settingsContentSummary(int aartiCount, int festivalCount, Object syncStatus) {
    return '$aartiCount આરતીઓ · $festivalCount તહેવારો ·\n$syncStatus';
  }

  @override
  String settingsContentLastRefresh(Object time) {
    return 'છેલ્લું રિફ્રેશ $time';
  }

  @override
  String get settingsContentSourceRemote => 'કૅશ કરેલી રિમોટ સામગ્રી';

  @override
  String get settingsContentSourceCached => 'કૅશ કરેલી ઑફલાઇન સામગ્રી';

  @override
  String get settingsContentSourceBundled => 'બંડલ કરેલી ઑફલાઇન સામગ્રી';

  @override
  String get settingsContentRefreshSuccess => 'સામગ્રી રિફ્રેશ થઈ.';

  @override
  String get settingsContentRefreshFailed => 'સામગ્રી રિફ્રેશ થઈ શકી નહીં.';

  @override
  String settingsSecondaryScriptFallback(Object scriptLabel) {
    return '$scriptLabel · જ્યારે એપ અને મુખ્ય લિપિ સમાન હોય ત્યારે બેકઅપ';
  }

  @override
  String settingsSecondaryScriptUsage(Object scriptLabel) {
    return '$scriptLabel · દ્વિતીય વાંચન મોડ અને ફોકસ મોડમાં ઉપયોગ';
  }

  @override
  String get settingsNameDialogTitle => 'તમારું નામ';

  @override
  String get settingsNameHint => 'તમારું નામ દાખલ કરો';

  @override
  String settingsActivityLogTitle(int count) {
    return 'ઍક્ટિવિટી લોગ ($count)';
  }

  @override
  String get settingsActivityLogEmpty => 'હજુ સુધી કોઈ પ્રવૃત્તિ નોંધાઈ નથી.';

  @override
  String get settingsActivityLogCleared => 'ઍક્ટિવિટી લોગ સાફ કરવામાં આવ્યો';
}
