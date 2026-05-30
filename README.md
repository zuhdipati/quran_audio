# Quran Audio App

A beautiful, feature-rich Flutter application designed for listening to the Holy Quran. This app provides a seamless and immersive experience, allowing users to browse Surahs, select their preferred Qori (reciter), and listen to high-quality audio with full playback controls.

## Key Features

* **Complete Surah List**: Browse and search through all 114 Surahs of the Quran.
* **Qori / Edition Selection**: Choose from a wide variety of Qoris. 
* **Advanced Audio Player**:
  * Play, Pause, and Resume capabilities.
  * Skip to Next or Previous Surah seamlessly.
  * Forward and Rewind by 10 seconds.
  * Interactive progress bar with exact duration.
  * Auto-play next Surah upon completion.
* **Offline Protection**: Safely caches essential data (using Hive) and prevents attempting to stream audio when the device loses internet connection, providing graceful error handling via Toast notifications.
* **Clean & Modern UI**: Built with a custom, aesthetically pleasing design system featuring responsive bottom sheets, customized app bars, and intuitive icons.

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
1. **[Al Quran Cloud API](https://alquran.cloud/api)**: Used to fetch the metadata and list of Surahs (`/quran/{edition}`).
2. **[Islamic Network CDN](https://cdn.islamic.network/)**: Used as the absolute source of truth for available Qoris (`/quran/info/by-surah/info.json`) and for streaming the actual `.mp3` audio files. This replaces legacy endpoints to guarantee 0% 404 errors during playback.

<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 00" src="https://github.com/user-attachments/assets/ae115542-5a68-4314-9abb-1b92c919c14b" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 12" src="https://github.com/user-attachments/assets/9710ef7c-e64d-409d-94e1-5e6726edf112" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 31" src="https://github.com/user-attachments/assets/0f563887-9924-4494-8cee-e1f788c0953f" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 19" src="https://github.com/user-attachments/assets/21c155cb-5206-49c7-bd45-fcbb78406501" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 52" src="https://github.com/user-attachments/assets/822d5384-1ede-44cb-b0ef-6f5cbf6d8393" />
<img width="390" height="844" alt="Simulator Screenshot - iPhone 16e - 2026-05-31 at 03 37 42" src="https://github.com/user-attachments/assets/75c06140-329e-4488-a1e4-5d1f8b1be57c" />
<img width="476" height="476" alt="Screenshot 2026-05-31 at 03 02 41" src="https://github.com/user-attachments/assets/f7958606-68bd-4927-90b3-499047031351" />

note: i am still using flutter 3.41.6
