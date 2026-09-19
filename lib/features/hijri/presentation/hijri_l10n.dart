import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/features/hijri/domain/entities/islamic_event_entity.dart';

extension IslamicEventL10n on IslamicEventEntity {
  bool _useEnglish(AppLocalizations l10n) => l10n.localeName == 'en';

  /// Falls back to the bundled Indonesian if no English has been written, so
  /// a new event added to the JSON never renders blank.
  String localizedName(AppLocalizations l10n) =>
      _useEnglish(l10n) && nameEn.isNotEmpty ? nameEn : name;

  String localizedDescription(AppLocalizations l10n) =>
      _useEnglish(l10n) && descriptionEn.isNotEmpty
      ? descriptionEn
      : description;
}
