// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'आरती संग्रह';

  @override
  String get appTagline => 'हिंदू प्रार्थनाओं और आरतियों का आपका संपूर्ण संग्रह';

  @override
  String get navigationHome => 'होम';

  @override
  String get navigationDiscover => 'खोज';

  @override
  String get navigationMyPuja => 'मेरी पूजा';

  @override
  String get navigationCollection => 'संग्रह';

  @override
  String get navigationSettings => 'सेटिंग्स';

  @override
  String navigationTabSemantics(Object label) {
    return '$label टैब';
  }

  @override
  String get commonBack => 'वापस';

  @override
  String get commonNext => 'अगला';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonSkip => 'छोड़ें';

  @override
  String get commonContinue => 'जारी रखें';

  @override
  String get commonDisabled => 'बंद';

  @override
  String get commonTapToChange => 'बदलने के लिए टैप करें';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageGujarati => 'गुजराती';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingWelcomeTitle => 'आरती संग्रह';

  @override
  String get onboardingWelcomeNativeTitle => 'आरती संग्रह';

  @override
  String get onboardingNameTitle => 'हम आपको\nक्या कहें?';

  @override
  String get onboardingNameSubtitle => 'हम आपके दैनिक अभिवादन को व्यक्तिगत बनाएंगे।';

  @override
  String get onboardingNameHint => 'आपका नाम';

  @override
  String get onboardingScriptTitle => 'अपनी पसंदीदा\nलिपि चुनें';

  @override
  String get onboardingScriptSubtitle => 'आप इसे बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String get onboardingPreferredLanguage => 'पसंदीदा भाषा';

  @override
  String get scriptDevanagari => 'देवनागरी';

  @override
  String get scriptEnglish => 'अंग्रेज़ी';

  @override
  String get scriptGujarati => 'गुजराती';

  @override
  String get scriptRoman => 'रोमन लिपि';

  @override
  String get onboardingReminderTitle => 'दैनिक पूजा\nस्मरण';

  @override
  String get onboardingReminderSubtitle => 'हम आपको आपकी पसंद के समय पर विनम्र स्मरण दिलाएँगे।';

  @override
  String get onboardingDailyReminder => 'दैनिक स्मरण';

  @override
  String onboardingReminderAt(Object time) {
    return 'स्मरण $time पर';
  }

  @override
  String get onboardingReminderTime => 'स्मरण समय';

  @override
  String get onboardingReminderBlessing => 'हर दिन की शुरुआत भक्ति और आंतरिक शांति के क्षण से करें।';

  @override
  String get homeGreetingInvocation => 'जय श्री कृष्ण,';

  @override
  String get homeAartiOfTheDay => 'आज की आरती';

  @override
  String get homeRecentlyVisited => 'हाल ही में देखी गई';

  @override
  String homeTodaySpecialLabel(Object dayName) {
    return '$dayName विशेष';
  }

  @override
  String homeTodaySubtitle(Object dayName, Object deityName) {
    return '$dayName · $deityName से शुरुआत करें';
  }

  @override
  String get weekdayMonday => 'सोमवार';

  @override
  String get weekdayTuesday => 'मंगलवार';

  @override
  String get weekdayWednesday => 'बुधवार';

  @override
  String get weekdayThursday => 'गुरुवार';

  @override
  String get weekdayFriday => 'शुक्रवार';

  @override
  String get weekdaySaturday => 'शनिवार';

  @override
  String get weekdaySunday => 'रविवार';

  @override
  String get deityShiva => 'शिव';

  @override
  String get deityHanuman => 'हनुमान';

  @override
  String get deityGanesha => 'गणेश';

  @override
  String get deityVishnu => 'विष्णु';

  @override
  String get deityDurga => 'दुर्गा';

  @override
  String get deityRama => 'राम';

  @override
  String get discoverBrowseByDeity => 'देवता के अनुसार देखें';

  @override
  String get discoverFilterByFestival => 'पर्व के अनुसार फ़िल्टर करें';

  @override
  String get discoverPopularAartis => 'लोकप्रिय आरतियाँ';

  @override
  String get discoverSearchPlaceholder => 'देवता, आरती या पर्व खोजें…';

  @override
  String discoverResultCount(int count) {
    return '$count मिले';
  }

  @override
  String get discoverNoAartisFound => 'कोई आरती नहीं मिली';

  @override
  String get discoverFestivalToday => 'आज';

  @override
  String discoverFestivalCountdown(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनों में',
      one: '1 दिन में',
    );
    return '$_temp0';
  }

  @override
  String get aartiDetailAddBookmark => 'बुकमार्क जोड़ें';

  @override
  String get aartiDetailRemoveBookmark => 'बुकमार्क हटाएँ';

  @override
  String aartiDetailVerseProgress(int current, int total) {
    return 'श्लोक $current में से $total';
  }

  @override
  String get aartiDetailFocusMode => 'ध्यान मोड';

  @override
  String get aartiDetailMantraCounter => 'मंत्र काउंटर';

  @override
  String get aartiDetailShare => 'साझा करें';

  @override
  String get aartiDetailVerseDataComingSoon => 'इस आरती के लिए श्लोक सामग्री जल्द आएगी।';

  @override
  String get aartiDetailFocusModeHeader => 'आरती ध्यान मोड';

  @override
  String get aartiDetailContentLyrics => 'पाठ';

  @override
  String get aartiDetailContentMeaning => 'अर्थ';

  @override
  String get focusModeSettingsTitle => 'पठन सेटिंग्स';

  @override
  String get focusModeSettingsReadingSurface => 'पठन सतह';

  @override
  String get focusModeSettingsTextSize => 'पाठ आकार';

  @override
  String get aartiDetailFocusSettingsDescription => 'अपनी सहेजी हुई ऐप सेटिंग्स बदले बिना इस ध्यान सत्र को समायोजित करें।';

  @override
  String get aartiDetailFocusSettingsFooterWithNext => 'अगली आरती पर जाने के लिए अंतिम श्लोक तक पहुँचें। ये बदलाव केवल इस ध्यान सत्र तक रहेंगे।';

  @override
  String get aartiDetailFocusSettingsFooterReset => 'ये बदलाव केवल इस ध्यान सत्र तक रहेंगे और ध्यान मोड फिर खोलने पर रीसेट हो जाएंगे।';

  @override
  String get aartiDetailShareTitle => 'आरती साझा करें';

  @override
  String get aartiDetailShareAsText => 'टेक्स्ट के रूप में';

  @override
  String get aartiDetailShareAsImage => 'चित्र के रूप में';

  @override
  String get focusModeOverlayNextAarti => 'अगली आरती';

  @override
  String focusModeOverlayNextNamed(Object title) {
    return 'अगली: $title';
  }

  @override
  String get focusModeOverlayPreviousAarti => 'पिछली आरती';

  @override
  String focusModeOverlayPreviousNamed(Object title) {
    return 'पिछली: $title';
  }

  @override
  String get focusModeOverlayCompleteSession => 'सत्र पूरा करें';

  @override
  String get focusModeOverlayInstructionAdvance => 'आगे बढ़ने के लिए हाइलाइट किए गए श्लोक पर या उसके नीचे टैप करें';

  @override
  String get focusModeOverlayInstructionPreviousNext => 'पिछले के लिए ऊपर टैप करें, अगले के लिए हाइलाइट किए गए श्लोक पर या उसके नीचे टैप करें';

  @override
  String get pujaFocusSessionHeader => 'पूजा ध्यान सत्र';

  @override
  String pujaSessionProgress(int current, int total) {
    return '$current में से $total';
  }

  @override
  String get pujaFocusSettingsDescription => 'फोकस सत्र में वर्तमान आरती कैसे दिखाई जाए, इसे समायोजित करें।';

  @override
  String get pujaFocusSettingsFooterContinue => 'अगली आरती पर जाने के लिए अंतिम श्लोक तक पहुँचें।';

  @override
  String get pujaFocusSettingsFooterComplete => 'इस फोकस सत्र को पूरा करने के लिए अंतिम श्लोक तक पहुँचें।';

  @override
  String get settingsTitleLeading => 'ऐप';

  @override
  String get settingsTitleTrailing => 'सेटिंग्स';

  @override
  String get settingsSectionProfile => 'प्रोफ़ाइल';

  @override
  String get settingsSectionAppearance => 'दिखावट';

  @override
  String get settingsSectionLanguageAndScript => 'भाषा और लिपि';

  @override
  String get settingsSectionNotifications => 'सूचनाएं';

  @override
  String get settingsSectionPujaSession => 'पूजा सत्र';

  @override
  String get settingsSectionPrivacy => 'गोपनीयता';

  @override
  String get settingsSectionSupport => 'सहायता';

  @override
  String get settingsSectionDiagnostics => 'डायग्नॉस्टिक्स';

  @override
  String get settingsSectionAbout => 'जानकारी';

  @override
  String get settingsDisplayName => 'प्रदर्शित नाम';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeLight => 'लाइट';

  @override
  String get settingsThemeDark => 'डार्क';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsTextSize => 'टेक्स्ट आकार';

  @override
  String get settingsAppLanguage => 'ऐप भाषा';

  @override
  String get settingsPrimaryScript => 'मुख्य लिपि';

  @override
  String get settingsSecondaryScript => 'द्वितीय लिपि';

  @override
  String get settingsDailyPujaReminder => 'दैनिक पूजा स्मरण';

  @override
  String get settingsReminderTime => 'स्मरण समय';

  @override
  String settingsReminderAt(Object time) {
    return '$time पर स्मरण';
  }

  @override
  String get settingsAutoPlay => 'ऑटो-प्ले';

  @override
  String get settingsAutoPlaySubtitle => 'पूजा सत्र में अगली आरती स्वतः चलाएं';

  @override
  String get settingsCrossfadeDuration => 'क्रॉसफेड अवधि';

  @override
  String settingsCrossfadeSubtitle(int seconds) {
    return '$seconds सेकंड का अंतराल';
  }

  @override
  String get settingsUsageAnalytics => 'उपयोग विश्लेषण';

  @override
  String get settingsAnalyticsEnabledSubtitle => 'स्क्रीन और फीचर इनसाइट्स के लिए सक्षम';

  @override
  String get settingsAnalyticsDisabledSubtitle => 'इस डिवाइस पर बंद';

  @override
  String get settingsSendFeedback => 'प्रतिक्रिया भेजें';

  @override
  String get settingsFeedbackSubtitle => 'समस्याएं बताएं, सुधार सुझाएं, या भक्तिपूर्ण प्रतिक्रिया साझा करें';

  @override
  String get settingsDevTools => 'डेवटूल्स';

  @override
  String get settingsDevToolsSubtitle => 'पूरा डायग्नॉस्टिक्स पेज खोलें';

  @override
  String get settingsActivityLog => 'एक्टिविटी लॉग';

  @override
  String settingsActivityLogSubtitle(int count) {
    return '$count प्रविष्टियां · रनटाइम गतिविधि देखें';
  }

  @override
  String get settingsShareActivityLog => 'एक्टिविटी लॉग साझा करें';

  @override
  String get settingsShareActivityLogSubtitle => 'समस्या-निवारण के लिए डायग्नॉस्टिक्स फ़ाइल निर्यात करें';

  @override
  String get settingsContent => 'सामग्री';

  @override
  String settingsAboutSubtitle(Object version) {
    return 'संस्करण $version · श्रद्धा से निर्मित';
  }

  @override
  String settingsContentSummary(int aartiCount, int festivalCount, Object syncStatus) {
    return '$aartiCount आरतियाँ · $festivalCount पर्व ·\n$syncStatus';
  }

  @override
  String settingsContentLastRefresh(Object time) {
    return 'अंतिम रिफ्रेश $time';
  }

  @override
  String get settingsContentSourceRemote => 'कैश की गई रिमोट सामग्री';

  @override
  String get settingsContentSourceCached => 'कैश की गई ऑफ़लाइन सामग्री';

  @override
  String get settingsContentSourceBundled => 'बंडल की गई ऑफ़लाइन सामग्री';

  @override
  String get settingsContentRefreshSuccess => 'सामग्री रिफ्रेश हुई।';

  @override
  String get settingsContentRefreshFailed => 'सामग्री रिफ्रेश नहीं हो सकी।';

  @override
  String settingsSecondaryScriptFallback(Object scriptLabel) {
    return '$scriptLabel · जब ऐप और मुख्य लिपि एक जैसी हों तो बैकअप';
  }

  @override
  String settingsSecondaryScriptUsage(Object scriptLabel) {
    return '$scriptLabel · द्वितीय पाठ मोड और फोकस मोड में उपयोग';
  }

  @override
  String get settingsNameDialogTitle => 'आपका नाम';

  @override
  String get settingsNameHint => 'अपना नाम दर्ज करें';

  @override
  String settingsActivityLogTitle(int count) {
    return 'एक्टिविटी लॉग ($count)';
  }

  @override
  String get settingsActivityLogEmpty => 'अभी कोई गतिविधि दर्ज नहीं हुई।';

  @override
  String get settingsActivityLogCleared => 'एक्टिविटी लॉग साफ़ किया गया';
}
