String baseUrl = 'https://api.alquran.cloud/v1';
String cdnBaseUrl = 'https://cdn.islamic.network';

String urlGetCdnInfo = '$cdnBaseUrl/quran/info/by-surah/info.json';
String urlGetAudioEditions = '$baseUrl/edition?format=audio';
String urlGetAllSurah(String edition) => '$baseUrl/quran/$edition';
String urlGetSurah(String surahNumber, String edition) =>
    '$baseUrl/surah/$surahNumber/$edition';
String urlSurahAudio(String edition, int surahNumber) =>
    '$cdnBaseUrl/quran/audio-surah/128/$edition/$surahNumber.mp3';

String hadithBaseUrl = 'https://cdn.zuhdipati.cloud';

String get urlHadithIndex => '$hadithBaseUrl/imaan/hadith/index.json';

String urlHadithChunk(String collectionId, int chunk) =>
    '$hadithBaseUrl/imaan/hadith/$collectionId/'
    '${chunk.toString().padLeft(3, '0')}.json';
