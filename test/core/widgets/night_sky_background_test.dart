import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/core/widgets/night_sky_background.dart';

Widget _host(Widget child, {bool disableAnimations = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

String _fingerprint(StarField field) => field.stars
    .map((s) => '${s.x},${s.y},${s.radius},${s.depth},${s.twinkleHarmonic}')
    .join('|');

void main() {
  group('StarField', () {
    test('is deterministic for a given seed', () {
      final a = StarField.generate(count: 150, seed: 1447);
      final b = StarField.generate(count: 150, seed: 1447);

      expect(_fingerprint(a), _fingerprint(b));
    });

    test('differs for a different seed', () {
      final a = StarField.generate(count: 150, seed: 1447);
      final b = StarField.generate(count: 150, seed: 99);

      expect(_fingerprint(a), isNot(_fingerprint(b)));
    });

    test('keeps every star in normalised space', () {
      final field = StarField.generate(count: 200, seed: 7);

      for (final star in [...field.stars, ...field.beacons]) {
        expect(star.x, inInclusiveRange(0.0, 1.0));
        expect(star.y, inInclusiveRange(0.0, 1.0));
        expect(star.depth, inInclusiveRange(0.0, 1.0));
      }
    });

    test('drifts nearer stars no slower than farther ones', () {
      final stars = StarField.generate(count: 200, seed: 7).stars.toList()
        ..sort((a, b) => a.depth.compareTo(b.depth));

      for (var i = 1; i < stars.length; i++) {
        expect(
          stars[i].driftWidthsPerCycle,
          greaterThanOrEqualTo(stars[i - 1].driftWidthsPerCycle),
        );
      }
    });

    test('uses whole-cycle harmonics so the loop is seamless', () {
      final field = StarField.generate(count: 200, seed: 7);

      for (final star in [...field.stars, ...field.beacons]) {
        expect(star.twinkleHarmonic, greaterThanOrEqualTo(1));
        expect(star.driftWidthsPerCycle, greaterThanOrEqualTo(1));
      }
    });
  });

  group('NightSkyBackground', () {
    testWidgets('drifts continuously by default', (tester) async {
      await tester.pumpWidget(_host(const NightSkyBackground()));
      await tester.pump();

      expect(tester.binding.transientCallbackCount, greaterThan(0));
    });

    testWidgets('parks on a static frame under reduce motion', (tester) async {
      await tester.pumpWidget(
        _host(const NightSkyBackground(), disableAnimations: true),
      );
      await tester.pumpAndSettle();

      expect(tester.binding.transientCallbackCount, 0);
      expect(find.byType(NightSkyBackground), findsOneWidget);
    });
  });
}
