/// Stable identifiers for user-facing errors.
///
/// Exceptions and failures are raised in the data layer, where there is no
/// BuildContext to localise with, and they travel to the UI as plain
/// strings through bloc state. Carrying a key instead of English prose lets
/// the presentation layer resolve the message in the active language via
/// `AppLocalizations.errorMessage`, without changing any state types.
///
/// Every key here must have a branch in the `errorMessage` select in both
/// ARB files; anything unrecognised falls through to the generic message.
abstract final class ErrorKeys {
  static const unexpected = 'unexpected';
  static const serverError = 'serverError';
  static const timeout = 'timeout';
  static const network = 'network';
  static const noInternet = 'noInternet';

  static const loadHadiths = 'loadHadiths';
  static const loadHadithCollections = 'loadHadithCollections';
  static const searchHadith = 'searchHadith';
  static const noHadithCollections = 'noHadithCollections';

  static const locationUnavailable = 'locationUnavailable';
  static const locationServiceOff = 'locationServiceOff';
  static const locationPermissionDenied = 'locationPermissionDenied';
  static const calculatePrayerTimes = 'calculatePrayerTimes';

  static const loadIslamicEvents = 'loadIslamicEvents';
  static const hijriOutOfRange = 'hijriOutOfRange';

  static const loadDuas = 'loadDuas';
  static const noDua = 'noDua';
  static const loadDzikir = 'loadDzikir';
  static const loadSalahGuide = 'loadSalahGuide';

  static const loadEditions = 'loadEditions';
  static const noAudioEditions = 'noAudioEditions';
  static const loadSurahs = 'loadSurahs';
  static const loadSurah = 'loadSurah';
  static const loadAudio = 'loadAudio';
  static const loadNatureSounds = 'loadNatureSounds';
  static const playSound = 'playSound';

  /// Every key, for the test that keeps the ARB selects in sync.
  static const all = [
    unexpected,
    serverError,
    timeout,
    network,
    noInternet,
    loadHadiths,
    loadHadithCollections,
    searchHadith,
    noHadithCollections,
    locationUnavailable,
    locationServiceOff,
    locationPermissionDenied,
    calculatePrayerTimes,
    loadIslamicEvents,
    hijriOutOfRange,
    loadDuas,
    noDua,
    loadDzikir,
    loadSalahGuide,
    loadEditions,
    noAudioEditions,
    loadSurahs,
    loadSurah,
    loadAudio,
    loadNatureSounds,
    playSound,
  ];
}
