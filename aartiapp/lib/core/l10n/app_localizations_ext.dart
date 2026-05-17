import 'package:flutter/widgets.dart';
import 'package:aartiapp/l10n/app_localizations.dart';

/// Convenience access to generated localized strings.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}