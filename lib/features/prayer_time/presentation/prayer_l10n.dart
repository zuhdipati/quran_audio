import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';

extension PrayerNameL10n on PrayerName {
  /// Display name in the active language. [PrayerNameX.label] stays as the
  /// stable non-localised name; the ARB select is keyed on the enum name.
  String localized(AppLocalizations l10n) => l10n.prayerName(name);
}
