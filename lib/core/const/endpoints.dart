String baseUrl = 'http://api.alquran.cloud/v1';

String urlgetAllEdition = '$baseUrl/edition?format=audio';
String urlGetAllSurah(String edition) => '$baseUrl/quran/$edition';
String urlGetSurah(String surahNumber, String edition) =>
    '$baseUrl/surah/$surahNumber/$edition';
