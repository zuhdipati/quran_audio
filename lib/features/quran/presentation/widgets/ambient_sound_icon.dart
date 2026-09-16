import 'package:flutter/material.dart';

IconData ambientSoundIcon(String id) => switch (id) {
  'rain' => Icons.umbrella_outlined,
  'drizzle' => Icons.grain_rounded,
  'thunderstorm' => Icons.thunderstorm_outlined,
  'rain_window' => Icons.window_outlined,
  'stream' => Icons.water_outlined,
  'waterfall' => Icons.landscape_outlined,
  'birds' => Icons.park_outlined,
  'ocean' => Icons.waves_rounded,
  'wind' => Icons.air_rounded,
  'night' => Icons.nights_stay_outlined,
  _ => Icons.graphic_eq_rounded,
};
