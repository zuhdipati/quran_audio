import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran Audio'**
  String get appTitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String inDays(int days);

  /// No description provided for @inDuration.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String inDuration(String duration);

  /// No description provided for @startingNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get startingNow;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @indonesianTranslationNote.
  ///
  /// In en, this message translates to:
  /// **'Translation in Bahasa Indonesia'**
  String get indonesianTranslationNote;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re back online'**
  String get backOnline;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'{key, select, unexpected{An unexpected error occurred} serverError{The server ran into a problem} timeout{The request timed out. Please try again.} network{A network error occurred} noInternet{No internet connection} loadHadiths{Couldn\'t load hadith} loadHadithCollections{Couldn\'t load hadith collections} searchHadith{Couldn\'t search hadith} noHadithCollections{No hadith collections available} locationUnavailable{Unable to determine your location} locationServiceOff{Location services are turned off} locationPermissionDenied{Location permission was denied} calculatePrayerTimes{Couldn\'t calculate prayer times} loadIslamicEvents{Couldn\'t load Islamic events} hijriOutOfRange{That Hijri date is outside the supported range} loadDuas{Couldn\'t load duas} noDua{No dua available} loadDzikir{Couldn\'t load dzikir} loadSalahGuide{Couldn\'t load the salah guide} loadEditions{Couldn\'t load reciters} noAudioEditions{No reciters found} loadSurahs{Couldn\'t load surahs} loadSurah{Couldn\'t load this surah} loadAudio{Couldn\'t load audio} loadNatureSounds{Couldn\'t load nature sounds} playSound{Couldn\'t play that sound} other{Something went wrong}}'**
  String errorMessage(String key);

  /// No description provided for @featureQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get featureQuran;

  /// No description provided for @featureHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get featureHijri;

  /// No description provided for @featureQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get featureQibla;

  /// No description provided for @featureTasbeeh.
  ///
  /// In en, this message translates to:
  /// **'Tasbeeh'**
  String get featureTasbeeh;

  /// No description provided for @featureCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get featureCalendar;

  /// No description provided for @featureDua.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get featureDua;

  /// No description provided for @featureHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get featureHadith;

  /// No description provided for @featureSalah.
  ///
  /// In en, this message translates to:
  /// **'Salah'**
  String get featureSalah;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Blessed night'**
  String get greetingNight;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'NEXT PRAYER'**
  String get nextPrayer;

  /// No description provided for @unableToLoadPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Unable to load prayer times'**
  String get unableToLoadPrayerTimes;

  /// No description provided for @dailyDua.
  ///
  /// In en, this message translates to:
  /// **'Daily Dua'**
  String get dailyDua;

  /// No description provided for @prayerName.
  ///
  /// In en, this message translates to:
  /// **'{prayer, select, imsak{Imsak} fajr{Fajr} sunrise{Sunrise} dhuhr{Dhuhr} asr{Asr} maghrib{Maghrib} isha{Isha} other{}}'**
  String prayerName(String prayer);

  /// No description provided for @hijriMonth.
  ///
  /// In en, this message translates to:
  /// **'{month, select, m1{Muharram} m2{Safar} m3{Rabi\' al-Awwal} m4{Rabi\' al-Thani} m5{Jumada al-Awwal} m6{Jumada al-Thani} m7{Rajab} m8{Sha\'ban} m9{Ramadan} m10{Shawwal} m11{Dhu al-Qi\'dah} m12{Dhu al-Hijjah} other{}}'**
  String hijriMonth(String month);

  /// No description provided for @hijriMonthShort.
  ///
  /// In en, this message translates to:
  /// **'{month, select, m1{MUH} m2{SAF} m3{RAW} m4{RTH} m5{JAW} m6{JTH} m7{RAJ} m8{SHA} m9{RAM} m10{SHW} m11{DHQ} m12{DHH} other{}}'**
  String hijriMonthShort(String month);

  /// No description provided for @hijriCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri Calendar'**
  String get hijriCalendarTitle;

  /// No description provided for @upcomingIslamicDays.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Islamic days'**
  String get upcomingIslamicDays;

  /// No description provided for @prayerCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Calendar'**
  String get prayerCalendarTitle;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get locating;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'{city} · set location'**
  String setLocation(String city);

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// No description provided for @qiblaFromTrueNorth.
  ///
  /// In en, this message translates to:
  /// **'Qibla is {degrees}° from true north'**
  String qiblaFromTrueNorth(String degrees);

  /// No description provided for @degreesFromNorth.
  ///
  /// In en, this message translates to:
  /// **'{degrees}° from North'**
  String degreesFromNorth(int degrees);

  /// No description provided for @noCompassHint.
  ///
  /// In en, this message translates to:
  /// **'No compass sensor detected. Face north, then turn clockwise by this angle.'**
  String get noCompassHint;

  /// No description provided for @calibrating.
  ///
  /// In en, this message translates to:
  /// **'Calibrating…'**
  String get calibrating;

  /// No description provided for @calibrateHint.
  ///
  /// In en, this message translates to:
  /// **'Move your phone in a figure-eight to calibrate the compass.'**
  String get calibrateHint;

  /// No description provided for @facingQibla.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Qibla'**
  String get facingQibla;

  /// No description provided for @holdSteadyHint.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone flat and steady.'**
  String get holdSteadyHint;

  /// No description provided for @turnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right {degrees}°'**
  String turnRight(int degrees);

  /// No description provided for @turnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left {degrees}°'**
  String turnLeft(int degrees);

  /// No description provided for @keepFlatHint.
  ///
  /// In en, this message translates to:
  /// **'Keep your phone flat, away from metal objects.'**
  String get keepFlatHint;

  /// No description provided for @tasbeehTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasbeeh'**
  String get tasbeehTitle;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap the circle to count'**
  String get tapToCount;

  /// No description provided for @roundsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{rounds} × {target} completed'**
  String roundsCompleted(int rounds, int target);

  /// No description provided for @countSemantics.
  ///
  /// In en, this message translates to:
  /// **'Count, {count}'**
  String countSemantics(int count);

  /// No description provided for @salahGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Salah Guide'**
  String get salahGuideTitle;

  /// No description provided for @salahReadings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get salahReadings;

  /// No description provided for @salahIntention.
  ///
  /// In en, this message translates to:
  /// **'Intention'**
  String get salahIntention;

  /// No description provided for @rakaatCount.
  ///
  /// In en, this message translates to:
  /// **'{count} rak\'ahs'**
  String rakaatCount(int count);

  /// No description provided for @duaTitle.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get duaTitle;

  /// No description provided for @searchDua.
  ///
  /// In en, this message translates to:
  /// **'Search dua…'**
  String get searchDua;

  /// No description provided for @noDuasFound.
  ///
  /// In en, this message translates to:
  /// **'No duas found.'**
  String get noDuasFound;

  /// No description provided for @duaCopied.
  ///
  /// In en, this message translates to:
  /// **'Dua copied'**
  String get duaCopied;

  /// No description provided for @hadithTitle.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get hadithTitle;

  /// No description provided for @unableToLoadHadith.
  ///
  /// In en, this message translates to:
  /// **'Unable to load hadith'**
  String get unableToLoadHadith;

  /// No description provided for @searchHadithHint.
  ///
  /// In en, this message translates to:
  /// **'Search hadith or type its number…'**
  String get searchHadithHint;

  /// No description provided for @searchScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All collections'**
  String get searchScopeAll;

  /// No description provided for @hadithRange.
  ///
  /// In en, this message translates to:
  /// **'Hadith {from}–{to} of {total}'**
  String hadithRange(String from, String to, String total);

  /// No description provided for @hadithResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String hadithResultCount(String count);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pageOf(String page, String total);

  /// No description provided for @goToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get goToPage;

  /// No description provided for @noHadithFound.
  ///
  /// In en, this message translates to:
  /// **'No hadith found.'**
  String get noHadithFound;

  /// No description provided for @hadithCount.
  ///
  /// In en, this message translates to:
  /// **'{count} hadith'**
  String hadithCount(String count);

  /// No description provided for @chooseNarrator.
  ///
  /// In en, this message translates to:
  /// **'Choose a narrator'**
  String get chooseNarrator;

  /// No description provided for @narratorLabel.
  ///
  /// In en, this message translates to:
  /// **'NARRATOR'**
  String get narratorLabel;

  /// No description provided for @hadithNumbered.
  ///
  /// In en, this message translates to:
  /// **'Hadith {number}'**
  String hadithNumbered(int number);

  /// No description provided for @hadithNumberedLong.
  ///
  /// In en, this message translates to:
  /// **'Hadith No. {number}'**
  String hadithNumberedLong(int number);

  /// No description provided for @searchSurah.
  ///
  /// In en, this message translates to:
  /// **'Search surah…'**
  String get searchSurah;

  /// No description provided for @noSurahsFound.
  ///
  /// In en, this message translates to:
  /// **'No surahs found.'**
  String get noSurahsFound;

  /// No description provided for @qoriOffline.
  ///
  /// In en, this message translates to:
  /// **'Qori selection is disabled while offline'**
  String get qoriOffline;

  /// No description provided for @audioOffline.
  ///
  /// In en, this message translates to:
  /// **'Audio playback is disabled while offline'**
  String get audioOffline;

  /// No description provided for @selectQori.
  ///
  /// In en, this message translates to:
  /// **'Select qori'**
  String get selectQori;

  /// No description provided for @recitedBy.
  ///
  /// In en, this message translates to:
  /// **'RECITED BY'**
  String get recitedBy;

  /// No description provided for @chooseQori.
  ///
  /// In en, this message translates to:
  /// **'Choose a Qori'**
  String get chooseQori;

  /// No description provided for @searchQori.
  ///
  /// In en, this message translates to:
  /// **'Search qori…'**
  String get searchQori;

  /// No description provided for @noQoriFound.
  ///
  /// In en, this message translates to:
  /// **'No qori found.'**
  String get noQoriFound;

  /// No description provided for @ayahCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs'**
  String ayahCount(int count);

  /// No description provided for @revelationType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, Meccan{Meccan} Medinan{Medinan} other{{type}}}'**
  String revelationType(String type);

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @surahNamed.
  ///
  /// In en, this message translates to:
  /// **'Surah {name}'**
  String surahNamed(String name);

  /// No description provided for @surahNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'SURAH {number}'**
  String surahNumberLabel(int number);

  /// No description provided for @natureSounds.
  ///
  /// In en, this message translates to:
  /// **'Nature sounds'**
  String get natureSounds;

  /// No description provided for @mixer.
  ///
  /// In en, this message translates to:
  /// **'Mixer'**
  String get mixer;

  /// No description provided for @soundMixer.
  ///
  /// In en, this message translates to:
  /// **'Sound mixer'**
  String get soundMixer;

  /// No description provided for @turnOffAll.
  ///
  /// In en, this message translates to:
  /// **'Turn off all'**
  String get turnOffAll;

  /// No description provided for @layerNatureSoundsHint.
  ///
  /// In en, this message translates to:
  /// **'Layer nature sounds under the recitation.'**
  String get layerNatureSoundsHint;

  /// No description provided for @recitation.
  ///
  /// In en, this message translates to:
  /// **'Recitation'**
  String get recitation;

  /// No description provided for @selectSoundHint.
  ///
  /// In en, this message translates to:
  /// **'Select a sound above to adjust its level.'**
  String get selectSoundHint;

  /// No description provided for @wikimediaCredit.
  ///
  /// In en, this message translates to:
  /// **'Recordings from Wikimedia Commons: {credits}.'**
  String wikimediaCredit(String credits);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageContentHint.
  ///
  /// In en, this message translates to:
  /// **'Hadith, dua, dzikir and the salah guide are translated in Bahasa Indonesia, whichever language you choose.'**
  String get languageContentHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
