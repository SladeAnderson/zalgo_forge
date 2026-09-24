import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zalgo_forge/components/imu_eye/component.dart';
import 'package:zalgo_forge/models/ZalgoPreset.model.dart';
import 'package:zalgo_forge/utilities/zalgo.dart';

void main() {
  group('summonsImu', () {
    test('answers to her name', () {
      expect(summonsImu('Imu'), isTrue);
      expect(summonsImu('imu sama'), isTrue);
      expect(summonsImu('Imu-sama'), isTrue);
      expect(summonsImu('praise IMU SAMA!'), isTrue);
    });

    test('sees through zalgo marks', () {
      final String cursed = zalgoify(
        'Imu sama',
        ZalgoOptions.fromPreset(ZalgoPreset.obliterated),
      );
      expect(summonsImu(cursed), isTrue);
    });

    test('ignores lookalikes', () {
      expect(summonsImu('immune'), isFalse);
      expect(summonsImu('imus'), isFalse);
      expect(summonsImu(''), isFalse);
      expect(summonsImu('from beyond the veil'), isFalse);
    });
  });

  group('ImuEye', () {
    testWidgets('shuts itself when it stops being visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImuEye(visible: true)));

      // Not pumpAndSettle: the iris pulses forever while the eye is open.
      await tester.pump(const Duration(milliseconds: 900));

      await tester.pumpWidget(const MaterialApp(home: ImuEye(visible: false)));

      // This is the assertion. pumpAndSettle only returns once every animation
      // has stopped, so it proves the lid closed and the pulse was stopped
      // with it. Without either, it times out.
      await tester.pumpAndSettle();

      expect(find.byType(ImuEye), findsOneWidget);
    });
  });
}
