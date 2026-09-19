# Quran Audio App

A beautiful, feature-rich Flutter application designed for listening to the Holy Quran. This app provides a seamless and immersive experience, allowing users to browse Surahs, select their preferred Qori (reciter), and listen to high-quality audio with full playback controls.

## Key Features

* **Prayer times on the home screen**: Fajr, Dzuhr, Asr, Maghrib and Isha with a countdown to the next prayer, calculated offline from your location (Kemenag RI parameters, Fajr 20° / Isha 18°).
* **Menu**: Quran, Hijri, Qibla, Tasbeeh, Calendar, Dua, Hadith and Salah, plus a **Daily Dua** with Arabic, transliteration and translation.
* **Quran audio player**:
  * Reciter list with clean names, Arabic names and photos.
  * Play/pause, next/previous surah, ±10 seconds, seek, auto-play next surah.
  * **Nature sound mixer**: rain, drizzle, thunderstorm, stream, waterfall, birdsong, ocean, wind and night sounds that play together with the recitation, each with its own volume.
* **Calendar**: month view with the prayer times for every day and the Hijri date.
* **Hijri**: Hijri month view and upcoming Islamic days.
* **Qibla**: compass pointing towards the Kaaba.
* **Tasbeeh**: counter with common dzikir, saved between sessions.
* **Dua** (226 duas), **Hadith** (Arbain An-Nawawi, 42 hadith) and **Salah** (niat and readings), all bundled as JSON in `assets/data` and available offline.

## Technology Stack 

This project strictly adheres to **Clean Architecture** principles and uses **BLoC (Business Logic Component)** for state management, ensuring a highly scalable, testable, and maintainable codebase.


### Core Libraries & Packages
* **[flutter_bloc](https://pub.dev/packages/flutter_bloc)**: For predictable state management.
* **[just_audio](https://pub.dev/packages/just_audio)**: A feature-rich audio player for Flutter used to handle MP3 streaming from the CDN.
* **[audio_video_progress_bar](https://pub.dev/packages/audio_video_progress_bar)**: Provides the interactive timeline/scrubber in the audio player UI.
* **[dio](https://pub.dev/packages/dio)**: A powerful HTTP client for Dart used for all network requests.
* **[hive](https://pub.dev/packages/hive)** & **hive_flutter**: A lightweight and blazing fast key-value database used for caching API responses (offline support).
* **[get_it](https://pub.dev/packages/get_it)**: For Dependency Injection (DI) and Service Locator implementation.
* **[go_router](https://pub.dev/packages/go_router)**: For declarative routing and navigation.
* **[internet_connection_checker_plus](https://pub.dev/packages/internet_connection_checker_plus)**: To monitor network connectivity status.
* **Testing (`flutter_test`, `mocktail`, `bloc_test`)**: Ensuring high reliability with nearly 100% test coverage across Unit and Widget tests.

### APIs & Data Sources
1. **[Al Quran Cloud API](https://alquran.cloud/api)**: surah metadata (`/quran/{edition}`) and reciter names (`/edition?format=audio`).
2. **[Islamic Network CDN](https://cdn.islamic.network/)**: list of available reciters and the surah `.mp3` streams.
3. **Bundled JSON (`assets/data`)**:
   * Duas from [equran.id](https://equran.id/doa) (sourced from Hisnul Muslim, with references).
   * Hadith Arbain An-Nawawi from [api.myquran.com](https://api.myquran.com).
   * Salah readings and niat; Al-Fatihah uses the Uthmani text from Al Quran Cloud.
   * Reciter photos from Wikimedia Commons via Wikipedia.
4. **Prayer times, Qibla and Hijri dates** are calculated on device with [adhan](https://pub.dev/packages/adhan) and [hijri](https://pub.dev/packages/hijri).

### Nature Sound Credits
The ambient recordings (served from the R2 bucket `imaan` under `sounds/`, downloaded on first use) come from Wikimedia Commons: Rain and Rain & Thunder by ezwa (public domain), Rain on Window by cori (public domain), Light Rainfall by Mijesty (CC BY-SA 4.0), Stream by jackthemurray (CC0), Waterfall by Benzband (CC BY-SA 3.0), Birdsong by Robert EA Harvey (CC BY-SA 4.0), Ocean Waves by Luftrum (CC BY 3.0), Forest Wind by W.carter (CC BY-SA 4.0), Night Chorus by JogiAsad (CC BY-SA 4.0). Source links are listed in `assets/data/ambient_sounds.json`.

<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 00" src="https://github.com/user-attachments/assets/ae115542-5a68-4314-9abb-1b92c919c14b" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 12" src="https://github.com/user-attachments/assets/9710ef7c-e64d-409d-94e1-5e6726edf112" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 31" src="https://github.com/user-attachments/assets/0f563887-9924-4494-8cee-e1f788c0953f" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 19" src="https://github.com/user-attachments/assets/21c155cb-5206-49c7-bd45-fcbb78406501" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 52" src="https://github.com/user-attachments/assets/822d5384-1ede-44cb-b0ef-6f5cbf6d8393" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 42" src="https://github.com/user-attachments/assets/75c06140-329e-4488-a1e4-5d1f8b1be57c" />
<img width="476" height="476" alt="Screenshot 2026-05-31 at 03 02 41" src="https://github.com/user-attachments/assets/f7958606-68bd-4927-90b3-499047031351" />

note: i am still using flutter 3.41.6
