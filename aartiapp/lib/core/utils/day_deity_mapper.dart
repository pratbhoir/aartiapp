import 'package:aartiapp/l10n/app_localizations.dart';

import '../../data/repositories/aarti_repository.dart';

/// Maps weekday (1=Mon..7=Sun) to a deity for "Aarti of the Day".
/// Based on traditional Hindu day-deity associations.
class DayDeityMapper {
  DayDeityMapper._();

  static const Map<int, String> _dayToDeity = {
    1: 'Shiva',     // Somvar (Monday)
    2: 'Hanuman',   // Mangalvar (Tuesday)
    3: 'Ganesha',   // Budhvar (Wednesday)
    4: 'Vishnu',    // Guruvar (Thursday)
    5: 'Durga',     // Shukravar (Friday)
    6: 'Hanuman',   // Shanivar (Saturday)
    7: 'Rama',      // Ravivar (Sunday)
  };

  static const Map<int, String> _dayToHindiName = {
    1: 'Somvar',
    2: 'Mangalvar',
    3: 'Budhvar',
    4: 'Guruvar',
    5: 'Shukravar',
    6: 'Shanivar',
    7: 'Ravivar',
  };

  static const Map<int, String> _dayToEnglishName = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  /// Returns the deity for today based on weekday.
  static String todayDeity() => _dayToDeity[DateTime.now().weekday] ?? 'Shiva';

  /// Returns the Hindi day name (e.g., 'Somvar').
  static String todayHindiName() =>
      _dayToHindiName[DateTime.now().weekday] ?? 'Somvar';

  /// Returns the English day name.
  static String todayEnglishName() =>
      _dayToEnglishName[DateTime.now().weekday] ?? 'Monday';

  /// Returns a subtitle like "Monday · Somvar · Begin with Shiva"
  static String todaySubtitle() =>
      '${todayEnglishName()} · ${todayHindiName()} · Begin with ${todayDeity()}';

  /// Returns a localized subtitle for the home hero area.
  static String todaySubtitleLocalized(AppLocalizations l10n) {
    return l10n.homeTodaySubtitle(
      _localizedWeekdayName(l10n, DateTime.now().weekday),
      _localizedDeityName(l10n, todayDeity()),
    );
  }

  /// Finds today's featured Aarti from the catalog.
  /// Falls back to first item if no match for today's deity.
  static int todayAartiIndex() {
    final deity = todayDeity();
    final aartis = AartiRepository.instance.aartis;
    final idx = aartis.indexWhere(
        (a) => a.deity.toLowerCase() == deity.toLowerCase());
    return idx >= 0 ? idx : 0;
  }

  /// Returns the special label, e.g. "Somvar Special"
  static String todaySpecialLabel() => '${todayHindiName()} Special';

  /// Returns a localized special label for surfaces like the home hero card.
  static String todaySpecialLabelLocalized(AppLocalizations l10n) {
    return l10n.homeTodaySpecialLabel(
      _localizedWeekdayName(l10n, DateTime.now().weekday),
    );
  }

  static String _localizedWeekdayName(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.weekdayMonday;
      case DateTime.tuesday:
        return l10n.weekdayTuesday;
      case DateTime.wednesday:
        return l10n.weekdayWednesday;
      case DateTime.thursday:
        return l10n.weekdayThursday;
      case DateTime.friday:
        return l10n.weekdayFriday;
      case DateTime.saturday:
        return l10n.weekdaySaturday;
      case DateTime.sunday:
      default:
        return l10n.weekdaySunday;
    }
  }

  static String _localizedDeityName(AppLocalizations l10n, String deity) {
    switch (deity.toLowerCase()) {
      case 'hanuman':
        return l10n.deityHanuman;
      case 'ganesha':
        return l10n.deityGanesha;
      case 'vishnu':
        return l10n.deityVishnu;
      case 'durga':
        return l10n.deityDurga;
      case 'rama':
        return l10n.deityRama;
      case 'shiva':
      default:
        return l10n.deityShiva;
    }
  }
}
