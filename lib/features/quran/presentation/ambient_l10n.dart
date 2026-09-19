import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';

extension AmbientSoundL10n on AmbientSoundEntity {
  /// The bundled sounds are already bilingual: `name` is Indonesian and
  /// `subtitle` is its English equivalent.
  String localizedName(AppLocalizations l10n) =>
      l10n.localeName == 'en' && subtitle.isNotEmpty ? subtitle : name;
}
