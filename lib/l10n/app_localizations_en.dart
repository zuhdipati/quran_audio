// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Quran Audio';

  @override
  String get tryAgain => 'Try again';

  @override
  String get next => 'Next';

  @override
  String get change => 'Change';

  @override
  String get reset => 'Reset';

  @override
  String get copy => 'Copy';

  @override
  String get seeAll => 'See all';

  @override
  String get all => 'All';

  @override
  String get source => 'Source';

  @override
  String get loading => 'Loading…';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String inDays(int days) {
    return 'in $days days';
  }

  @override
  String inDuration(String duration) {
    return 'in $duration';
  }

  @override
  String get startingNow => 'now';

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get indonesianTranslationNote => 'Translation in Bahasa Indonesia';

  @override
  String get backOnline => 'You\'re back online';

  @override
  String errorMessage(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'unexpected': 'An unexpected error occurred',
      'serverError': 'The server ran into a problem',
      'timeout': 'The request timed out. Please try again.',
      'network': 'A network error occurred',
      'noInternet': 'No internet connection',
      'loadHadiths': 'Couldn\'t load hadith',
      'loadHadithCollections': 'Couldn\'t load hadith collections',
      'searchHadith': 'Couldn\'t search hadith',
      'noHadithCollections': 'No hadith collections available',
      'locationUnavailable': 'Unable to determine your location',
      'locationServiceOff': 'Location services are turned off',
      'locationPermissionDenied': 'Location permission was denied',
      'calculatePrayerTimes': 'Couldn\'t calculate prayer times',
      'loadIslamicEvents': 'Couldn\'t load Islamic events',
      'hijriOutOfRange': 'That Hijri date is outside the supported range',
      'loadDuas': 'Couldn\'t load duas',
      'noDua': 'No dua available',
      'loadDzikir': 'Couldn\'t load dzikir',
      'loadSalahGuide': 'Couldn\'t load the salah guide',
      'loadEditions': 'Couldn\'t load reciters',
      'noAudioEditions': 'No reciters found',
      'loadSurahs': 'Couldn\'t load surahs',
      'loadSurah': 'Couldn\'t load this surah',
      'loadAudio': 'Couldn\'t load audio',
      'loadNatureSounds': 'Couldn\'t load nature sounds',
      'playSound': 'Couldn\'t play that sound',
      'other': 'Something went wrong',
    });
    return '$_temp0';
  }

  @override
  String get featureQuran => 'Quran';

  @override
  String get featureHijri => 'Hijri';

  @override
  String get featureQibla => 'Qibla';

  @override
  String get featureTasbeeh => 'Tasbeeh';

  @override
  String get featureCalendar => 'Calendar';

  @override
  String get featureDua => 'Dua';

  @override
  String get featureHadith => 'Hadith';

  @override
  String get featureSalah => 'Salah';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Blessed night';

  @override
  String get nextPrayer => 'NEXT PRAYER';

  @override
  String get unableToLoadPrayerTimes => 'Unable to load prayer times';

  @override
  String get dailyDua => 'Daily Dua';

  @override
  String prayerName(String prayer) {
    String _temp0 = intl.Intl.selectLogic(prayer, {
      'imsak': 'Imsak',
      'fajr': 'Fajr',
      'sunrise': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String hijriMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharram',
      'm2': 'Safar',
      'm3': 'Rabi\' al-Awwal',
      'm4': 'Rabi\' al-Thani',
      'm5': 'Jumada al-Awwal',
      'm6': 'Jumada al-Thani',
      'm7': 'Rajab',
      'm8': 'Sha\'ban',
      'm9': 'Ramadan',
      'm10': 'Shawwal',
      'm11': 'Dhu al-Qi\'dah',
      'm12': 'Dhu al-Hijjah',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String hijriMonthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'MUH',
      'm2': 'SAF',
      'm3': 'RAW',
      'm4': 'RTH',
      'm5': 'JAW',
      'm6': 'JTH',
      'm7': 'RAJ',
      'm8': 'SHA',
      'm9': 'RAM',
      'm10': 'SHW',
      'm11': 'DHQ',
      'm12': 'DHH',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get hijriCalendarTitle => 'Hijri Calendar';

  @override
  String get upcomingIslamicDays => 'Upcoming Islamic days';

  @override
  String get prayerCalendarTitle => 'Prayer Calendar';

  @override
  String get locating => 'Locating…';

  @override
  String setLocation(String city) {
    return '$city · set location';
  }

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String qiblaFromTrueNorth(String degrees) {
    return 'Qibla is $degrees° from true north';
  }

  @override
  String degreesFromNorth(int degrees) {
    return '$degrees° from North';
  }

  @override
  String get noCompassHint =>
      'No compass sensor detected. Face north, then turn clockwise by this angle.';

  @override
  String get calibrating => 'Calibrating…';

  @override
  String get calibrateHint =>
      'Move your phone in a figure-eight to calibrate the compass.';

  @override
  String get facingQibla => 'You are facing the Qibla';

  @override
  String get holdSteadyHint => 'Hold your phone flat and steady.';

  @override
  String turnRight(int degrees) {
    return 'Turn right $degrees°';
  }

  @override
  String turnLeft(int degrees) {
    return 'Turn left $degrees°';
  }

  @override
  String get keepFlatHint => 'Keep your phone flat, away from metal objects.';

  @override
  String get tasbeehTitle => 'Tasbeeh';

  @override
  String get tapToCount => 'Tap the circle to count';

  @override
  String roundsCompleted(int rounds, int target) {
    return '$rounds × $target completed';
  }

  @override
  String countSemantics(int count) {
    return 'Count, $count';
  }

  @override
  String get salahGuideTitle => 'Salah Guide';

  @override
  String get salahReadings => 'Readings';

  @override
  String get salahIntention => 'Intention';

  @override
  String rakaatCount(int count) {
    return '$count rak\'ahs';
  }

  @override
  String get duaTitle => 'Dua';

  @override
  String get searchDua => 'Search dua…';

  @override
  String get noDuasFound => 'No duas found.';

  @override
  String get duaCopied => 'Dua copied';

  @override
  String get hadithTitle => 'Hadith';

  @override
  String get unableToLoadHadith => 'Unable to load hadith';

  @override
  String get searchHadithHint => 'Search hadith or type its number…';

  @override
  String get searchScopeAll => 'All collections';

  @override
  String hadithRange(String from, String to, String total) {
    return 'Hadith $from–$to of $total';
  }

  @override
  String hadithResultCount(String count) {
    return '$count results';
  }

  @override
  String pageOf(String page, String total) {
    return 'Page $page of $total';
  }

  @override
  String get goToPage => 'Go to page';

  @override
  String get noHadithFound => 'No hadith found.';

  @override
  String hadithCount(String count) {
    return '$count hadith';
  }

  @override
  String get chooseNarrator => 'Choose a narrator';

  @override
  String get narratorLabel => 'NARRATOR';

  @override
  String hadithNumbered(int number) {
    return 'Hadith $number';
  }

  @override
  String hadithNumberedLong(int number) {
    return 'Hadith No. $number';
  }

  @override
  String get searchSurah => 'Search surah…';

  @override
  String get noSurahsFound => 'No surahs found.';

  @override
  String get qoriOffline => 'Qori selection is disabled while offline';

  @override
  String get audioOffline => 'Audio playback is disabled while offline';

  @override
  String get selectQori => 'Select qori';

  @override
  String get recitedBy => 'RECITED BY';

  @override
  String get chooseQori => 'Choose a Qori';

  @override
  String get searchQori => 'Search qori…';

  @override
  String get noQoriFound => 'No qori found.';

  @override
  String ayahCount(int count) {
    return '$count ayahs';
  }

  @override
  String revelationType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'Meccan': 'Meccan',
      'Medinan': 'Medinan',
      'other': '$type',
    });
    return '$_temp0';
  }

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String surahNamed(String name) {
    return 'Surah $name';
  }

  @override
  String surahNumberLabel(int number) {
    return 'SURAH $number';
  }

  @override
  String get natureSounds => 'Nature sounds';

  @override
  String get mixer => 'Mixer';

  @override
  String get soundMixer => 'Sound mixer';

  @override
  String get turnOffAll => 'Turn off all';

  @override
  String get layerNatureSoundsHint =>
      'Layer nature sounds under the recitation.';

  @override
  String get recitation => 'Recitation';

  @override
  String get selectSoundHint => 'Select a sound above to adjust its level.';

  @override
  String wikimediaCredit(String credits) {
    return 'Recordings from Wikimedia Commons: $credits.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Use device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageContentHint =>
      'Hadith, dua, dzikir and the salah guide are translated in Bahasa Indonesia, whichever language you choose.';
}
