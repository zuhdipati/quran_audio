String baseUrl = 'http://api.alquran.cloud/v1';
String cdnBaseUrl = 'https://cdn.islamic.network';

String urlGetCdnInfo = '$cdnBaseUrl/quran/info/by-surah/info.json';
String urlGetAllSurah(String edition) => '$baseUrl/quran/$edition';
String urlGetSurah(String surahNumber, String edition) =>
    '$baseUrl/surah/$surahNumber/$edition';
