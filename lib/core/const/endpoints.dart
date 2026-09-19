String baseUrl = 'https://api.alquran.cloud/v1';
String cdnBaseUrl = 'https://cdn.islamic.network';

String urlGetCdnInfo = '$cdnBaseUrl/quran/info/by-surah/info.json';
String urlGetAudioEditions = '$baseUrl/edition?format=audio';
String urlGetAllSurah(String edition) => '$baseUrl/quran/$edition';
String urlGetSurah(String surahNumber, String edition) =>
    '$baseUrl/surah/$surahNumber/$edition';
String urlSurahAudio(String edition, int surahNumber) =>
    '$cdnBaseUrl/quran/audio-surah/128/$edition/$surahNumber.mp3';
String hadithApiBaseUrl = 'https://hadith.zuhdipati.cloud/v1';
String get urlHadithCollections => '$hadithApiBaseUrl/collections';
String urlHadithPage(String collectionId) =>
    '$hadithApiBaseUrl/collections/$collectionId/hadiths';
String get urlHadithSearch => '$hadithApiBaseUrl/search';
String soundsBaseUrl = 'https://imaan.zuhdipati.cloud/sounds';
String urlAmbientSound(String file) => '$soundsBaseUrl/$file';
