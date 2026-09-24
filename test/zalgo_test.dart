import 'package:flutter_test/flutter_test.dart';
import 'package:zalgo_forge/models/ZalgoPreset.model.dart';
import 'package:zalgo_forge/utilities/zalgo.dart';

void main() {
  test('is deterministic for a given seed', () {
    const ZalgoOptions options = ZalgoOptions(chaos: 0.5, seed: 42);
    expect(zalgoify('hex', options), zalgoify('hex', options));
  });
  test('different seeds diverge', () {
    expect(
      zalgoify('hex', const ZalgoOptions(chaos: 0.5, seed: 1)),
      isNot(zalgoify('hex', const ZalgoOptions(chaos: 0.5, seed: 2))),
    );
  });
  test('zero chaos is a no-op', () {
    expect(zalgoify('hex', const ZalgoOptions(chaos: 0, strike: 0)), 'hex');
  });
  test('balance +1 removes the lower band', () {
    const ZalgoOptions options = ZalgoOptions(chaos: 1, balance: 1);
    expect(options.belowCount, 0);
    expect(options.aboveCount, greaterThan(0));
  });
  test('stripZalgo round-trips', () {
    const ZalgoOptions options = ZalgoOptions(chaos: 0.8, seed: 3);
    expect(stripZalgo(zalgoify('hello world', options)), 'hello world');
  });
  test('presets are reachable and detected', () {
    final ZalgoOptions options = ZalgoOptions.fromPreset(ZalgoPreset.cursed);
    expect(options.matchingPreset(ZalgoPreset.builtIns), ZalgoPreset.cursed);
  });
  test('newlines survive', () {
    const ZalgoOptions options = ZalgoOptions(
      chaos: 1,
      corruptSpaces: true,
      seed: 1,
    );
    expect(zalgoify('a\nb', options).split('\n').length, 2);
  });
}
