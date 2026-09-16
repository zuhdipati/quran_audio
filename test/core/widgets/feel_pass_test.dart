import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/core/widgets/celestial_loader.dart';
import 'package:quran_audio/core/widgets/entrance.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';

/// Records haptic calls so tests can assert feedback fired without a device.
List<String> _captureHaptics(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    },
  );
  return calls;
}

Widget _host(Widget child, {bool disableAnimations = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('CelestialLoader', () {
    testWidgets('animates continuously by default', (tester) async {
      await tester.pumpWidget(_host(const CelestialLoader()));
      await tester.pump();

      expect(tester.binding.transientCallbackCount, greaterThan(0));
    });

    testWidgets('holds a static frame when reduce motion is on', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const CelestialLoader(), disableAnimations: true),
      );
      await tester.pumpAndSettle();

      expect(tester.binding.transientCallbackCount, 0);
      expect(find.byType(CelestialLoader), findsOneWidget);
    });
  });

  group('StaggeredEntrance', () {
    Opacity opacityOf(WidgetTester tester) => tester.widget<Opacity>(
      find.ancestor(of: find.text('row'), matching: find.byType(Opacity)).first,
    );

    testWidgets('settles fully visible', (tester) async {
      await tester.pumpWidget(
        _host(const StaggeredEntrance(index: 0, child: Text('row'))),
      );
      expect(opacityOf(tester).opacity, lessThan(1.0));

      await tester.pumpAndSettle();
      expect(opacityOf(tester).opacity, 1.0);
    });

    testWidgets('skips animation past the cap', (tester) async {
      await tester.pumpWidget(
        _host(
          const StaggeredEntrance(
            index: 99,
            maxAnimatedIndex: 10,
            child: Text('row'),
          ),
        ),
      );

      expect(opacityOf(tester).opacity, 1.0);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('skips animation when reduce motion is on', (tester) async {
      await tester.pumpWidget(
        _host(
          const StaggeredEntrance(index: 0, child: Text('row')),
          disableAnimations: true,
        ),
      );

      expect(opacityOf(tester).opacity, 1.0);
    });

    testWidgets('does not replay on rebuild', (tester) async {
      await tester.pumpWidget(
        _host(const StaggeredEntrance(index: 0, child: Text('row'))),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _host(const StaggeredEntrance(index: 0, child: Text('row'))),
      );
      expect(opacityOf(tester).opacity, 1.0);
    });
  });

  group('SurfaceCard', () {
    testWidgets('fires a haptic when tapped', (tester) async {
      final haptics = _captureHaptics(tester);
      await tester.pumpWidget(
        _host(SurfaceCard(onTap: () {}, child: const Text('card'))),
      );

      await tester.tap(find.text('card'));
      await tester.pumpAndSettle();

      expect(haptics, isNotEmpty);
    });

    testWidgets('stays silent when it is not tappable', (tester) async {
      final haptics = _captureHaptics(tester);
      await tester.pumpWidget(
        _host(const SurfaceCard(child: Text('card'))),
      );

      await tester.tap(find.text('card'));
      await tester.pumpAndSettle();

      expect(haptics, isEmpty);
    });

    testWidgets('scales down while held', (tester) async {
      await tester.pumpWidget(
        _host(SurfaceCard(onTap: () {}, child: const Text('card'))),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('card')),
      );
      await tester.pumpAndSettle();

      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, lessThan(1.0));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        1.0,
      );
    });
  });
}
