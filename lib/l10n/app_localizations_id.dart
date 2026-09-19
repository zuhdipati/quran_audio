// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Quran Audio';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get next => 'Berikutnya';

  @override
  String get change => 'Ganti';

  @override
  String get reset => 'Atur ulang';

  @override
  String get copy => 'Salin';

  @override
  String get seeAll => 'Lihat semua';

  @override
  String get all => 'Semua';

  @override
  String get source => 'Sumber';

  @override
  String get loading => 'Memuat…';

  @override
  String get today => 'Hari ini';

  @override
  String get tomorrow => 'Besok';

  @override
  String inDays(int days) {
    return '$days hari lagi';
  }

  @override
  String inDuration(String duration) {
    return '$duration lagi';
  }

  @override
  String get startingNow => 'sekarang';

  @override
  String durationMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours j $minutes mnt';
  }

  @override
  String get indonesianTranslationNote => 'Terjemahan Bahasa Indonesia';

  @override
  String get backOnline => 'Anda kembali online';

  @override
  String errorMessage(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'unexpected': 'Terjadi kesalahan tak terduga',
      'serverError': 'Server sedang bermasalah',
      'timeout': 'Permintaan terlalu lama. Silakan coba lagi.',
      'network': 'Terjadi kesalahan jaringan',
      'noInternet': 'Tidak ada koneksi internet',
      'loadHadiths': 'Gagal memuat hadits',
      'loadHadithCollections': 'Gagal memuat koleksi hadits',
      'searchHadith': 'Gagal mencari hadits',
      'noHadithCollections': 'Tidak ada koleksi hadits',
      'locationUnavailable': 'Tidak dapat menentukan lokasi Anda',
      'locationServiceOff': 'Layanan lokasi sedang nonaktif',
      'locationPermissionDenied': 'Izin lokasi ditolak',
      'calculatePrayerTimes': 'Gagal menghitung jadwal shalat',
      'loadIslamicEvents': 'Gagal memuat hari besar Islam',
      'hijriOutOfRange': 'Tanggal Hijriah di luar rentang yang didukung',
      'loadDuas': 'Gagal memuat doa',
      'noDua': 'Tidak ada doa',
      'loadDzikir': 'Gagal memuat dzikir',
      'loadSalahGuide': 'Gagal memuat panduan shalat',
      'loadEditions': 'Gagal memuat daftar qori',
      'noAudioEditions': 'Qori tidak ditemukan',
      'loadSurahs': 'Gagal memuat daftar surah',
      'loadSurah': 'Gagal memuat surah ini',
      'loadAudio': 'Gagal memuat audio',
      'loadNatureSounds': 'Gagal memuat suara alam',
      'playSound': 'Gagal memutar suara',
      'other': 'Terjadi kesalahan',
    });
    return '$_temp0';
  }

  @override
  String get featureQuran => 'Al-Qur\'an';

  @override
  String get featureHijri => 'Hijriah';

  @override
  String get featureQibla => 'Kiblat';

  @override
  String get featureTasbeeh => 'Tasbih';

  @override
  String get featureCalendar => 'Kalender';

  @override
  String get featureDua => 'Doa';

  @override
  String get featureHadith => 'Hadits';

  @override
  String get featureSalah => 'Shalat';

  @override
  String get greetingMorning => 'Selamat pagi';

  @override
  String get greetingAfternoon => 'Selamat siang';

  @override
  String get greetingEvening => 'Selamat sore';

  @override
  String get greetingNight => 'Selamat malam';

  @override
  String get nextPrayer => 'SHALAT BERIKUTNYA';

  @override
  String get unableToLoadPrayerTimes => 'Gagal memuat jadwal shalat';

  @override
  String get dailyDua => 'Doa Harian';

  @override
  String prayerName(String prayer) {
    String _temp0 = intl.Intl.selectLogic(prayer, {
      'imsak': 'Imsak',
      'fajr': 'Subuh',
      'sunrise': 'Terbit',
      'dhuhr': 'Dzuhur',
      'asr': 'Ashar',
      'maghrib': 'Maghrib',
      'isha': 'Isya',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String hijriMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharram',
      'm2': 'Safar',
      'm3': 'Rabiul Awal',
      'm4': 'Rabiul Akhir',
      'm5': 'Jumadil Awal',
      'm6': 'Jumadil Akhir',
      'm7': 'Rajab',
      'm8': 'Sya\'ban',
      'm9': 'Ramadhan',
      'm10': 'Syawal',
      'm11': 'Dzulqa\'dah',
      'm12': 'Dzulhijjah',
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
      'm4': 'RAK',
      'm5': 'JAW',
      'm6': 'JAK',
      'm7': 'RAJ',
      'm8': 'SYA',
      'm9': 'RAM',
      'm10': 'SYW',
      'm11': 'DZQ',
      'm12': 'DZH',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get hijriCalendarTitle => 'Kalender Hijriah';

  @override
  String get upcomingIslamicDays => 'Hari besar Islam mendatang';

  @override
  String get prayerCalendarTitle => 'Kalender Shalat';

  @override
  String get locating => 'Mencari lokasi…';

  @override
  String setLocation(String city) {
    return '$city · atur lokasi';
  }

  @override
  String get qiblaTitle => 'Kiblat';

  @override
  String qiblaFromTrueNorth(String degrees) {
    return 'Kiblat berada $degrees° dari utara sejati';
  }

  @override
  String degreesFromNorth(int degrees) {
    return '$degrees° dari Utara';
  }

  @override
  String get noCompassHint =>
      'Sensor kompas tidak terdeteksi. Hadap ke utara, lalu putar searah jarum jam sebesar sudut ini.';

  @override
  String get calibrating => 'Mengkalibrasi…';

  @override
  String get calibrateHint =>
      'Gerakkan ponsel membentuk angka delapan untuk mengkalibrasi kompas.';

  @override
  String get facingQibla => 'Anda sudah menghadap kiblat';

  @override
  String get holdSteadyHint => 'Pegang ponsel mendatar dan tetap stabil.';

  @override
  String turnRight(int degrees) {
    return 'Putar ke kanan $degrees°';
  }

  @override
  String turnLeft(int degrees) {
    return 'Putar ke kiri $degrees°';
  }

  @override
  String get keepFlatHint =>
      'Jaga ponsel tetap mendatar dan jauh dari benda logam.';

  @override
  String get tasbeehTitle => 'Tasbih';

  @override
  String get tapToCount => 'Ketuk lingkaran untuk menghitung';

  @override
  String roundsCompleted(int rounds, int target) {
    return '$rounds × $target selesai';
  }

  @override
  String countSemantics(int count) {
    return 'Hitungan, $count';
  }

  @override
  String get salahGuideTitle => 'Panduan Shalat';

  @override
  String get salahReadings => 'Bacaan';

  @override
  String get salahIntention => 'Niat';

  @override
  String rakaatCount(int count) {
    return '$count rakaat';
  }

  @override
  String get duaTitle => 'Doa';

  @override
  String get searchDua => 'Cari doa…';

  @override
  String get noDuasFound => 'Doa tidak ditemukan.';

  @override
  String get duaCopied => 'Doa disalin';

  @override
  String get hadithTitle => 'Hadits';

  @override
  String get unableToLoadHadith => 'Gagal memuat hadits';

  @override
  String get searchHadithHint => 'Cari hadits atau ketik nomornya…';

  @override
  String get searchScopeAll => 'Semua kitab';

  @override
  String hadithRange(String from, String to, String total) {
    return 'Hadits $from–$to dari $total';
  }

  @override
  String hadithResultCount(String count) {
    return '$count hasil';
  }

  @override
  String pageOf(String page, String total) {
    return 'Halaman $page dari $total';
  }

  @override
  String get goToPage => 'Buka halaman';

  @override
  String get noHadithFound => 'Hadits tidak ditemukan.';

  @override
  String hadithCount(String count) {
    return '$count hadits';
  }

  @override
  String get chooseNarrator => 'Pilih perawi';

  @override
  String get narratorLabel => 'PERAWI';

  @override
  String hadithNumbered(int number) {
    return 'Hadits $number';
  }

  @override
  String hadithNumberedLong(int number) {
    return 'Hadits No. $number';
  }

  @override
  String get searchSurah => 'Cari surah…';

  @override
  String get noSurahsFound => 'Surah tidak ditemukan.';

  @override
  String get qoriOffline => 'Pemilihan qori tidak tersedia saat offline';

  @override
  String get audioOffline => 'Pemutaran audio tidak tersedia saat offline';

  @override
  String get selectQori => 'Pilih qori';

  @override
  String get recitedBy => 'DIBACAKAN OLEH';

  @override
  String get chooseQori => 'Pilih Qori';

  @override
  String get searchQori => 'Cari qori…';

  @override
  String get noQoriFound => 'Qori tidak ditemukan.';

  @override
  String ayahCount(int count) {
    return '$count ayat';
  }

  @override
  String revelationType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'Meccan': 'Makkiyah',
      'Medinan': 'Madaniyah',
      'other': '$type',
    });
    return '$_temp0';
  }

  @override
  String get nowPlaying => 'Sedang Diputar';

  @override
  String surahNamed(String name) {
    return 'Surah $name';
  }

  @override
  String surahNumberLabel(int number) {
    return 'SURAH $number';
  }

  @override
  String get natureSounds => 'Suara alam';

  @override
  String get mixer => 'Mixer';

  @override
  String get soundMixer => 'Mixer suara';

  @override
  String get turnOffAll => 'Matikan semua';

  @override
  String get layerNatureSoundsHint => 'Tambahkan suara alam di bawah bacaan.';

  @override
  String get recitation => 'Bacaan';

  @override
  String get selectSoundHint => 'Pilih suara di atas untuk mengatur volumenya.';

  @override
  String wikimediaCredit(String credits) {
    return 'Rekaman dari Wikimedia Commons: $credits.';
  }

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Ikuti bahasa perangkat';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageContentHint =>
      'Hadits, doa, dzikir, dan panduan shalat tersedia dalam terjemahan Bahasa Indonesia, apa pun bahasa yang Anda pilih.';
}
