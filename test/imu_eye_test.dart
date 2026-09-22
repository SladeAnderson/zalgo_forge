import 'package:flutter_test/flutter_test.dart';
import 'package:zalgo_forge/components/imu_eye/component.dart';
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
}
