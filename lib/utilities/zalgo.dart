import 'dart:math';

import 'package:characters/characters.dart';
import 'package:zalgo_forge/models/ZalgoPreset.model.dart';

/// Marks that stack *above* the base character.
const List<String> _above = <String>[
  '\u030d',
  '\u030e',
  '\u0304',
  '\u0305',
  '\u033f',
  '\u0311',
  '\u0306',
  '\u0310',
  '\u0352',
  '\u0357',
  '\u0351',
  '\u0307',
  '\u0308',
  '\u030a',
  '\u0342',
  '\u0343',
  '\u0344',
  '\u034a',
  '\u034b',
  '\u034c',
  '\u0303',
  '\u0302',
  '\u030c',
  '\u0350',
  '\u0300',
  '\u0301',
  '\u030b',
  '\u030f',
  '\u0312',
  '\u0313',
  '\u0314',
  '\u033d',
  '\u0309',
  '\u0363',
  '\u0364',
  '\u0365',
  '\u0366',
  '\u0367',
  '\u0368',
  '\u0369',
  '\u036a',
  '\u036b',
  '\u036c',
  '\u036d',
  '\u036e',
  '\u036f',
  '\u033e',
  '\u035b',
  '\u031a',
];

/// Marks that strike *through* the character.
const List<String> _middle = <String>[
  '\u0315',
  '\u031b',
  '\u0340',
  '\u0341',
  '\u0358',
  '\u0321',
  '\u0322',
  '\u0327',
  '\u0328',
  '\u0334',
  '\u0335',
  '\u0336',
  '\u034f',
  '\u035c',
  '\u035d',
  '\u035e',
  '\u035f',
  '\u0360',
  '\u0362',
  '\u0338',
  '\u0337',
  '\u0361',
  '\u0489',
];

/// Marks that hang *below* the character
const List<String> _below = <String>[
  '\u0316',
  '\u0317',
  '\u0318',
  '\u0319',
  '\u031c',
  '\u031d',
  '\u031e',
  '\u031f',
  '\u0320',
  '\u0324',
  '\u0325',
  '\u0326',
  '\u0329',
  '\u032a',
  '\u032b',
  '\u032c',
  '\u032d',
  '\u032e',
  '\u032f',
  '\u0330',
  '\u0331',
  '\u0332',
  '\u0333',
  '\u0339',
  '\u033a',
  '\u033b',
  '\u033c',
  '\u0345',
  '\u0347',
  '\u0348',
  '\u0349',
  '\u034d',
  '\u034e',
  '\u0353',
  '\u0354',
  '\u0355',
  '\u0356',
  '\u0359',
  '\u035a',
  '\u0323',
];

/// Named points in the option space. Dart 3 enhanced enums carry fields, so
/// a preset *is* its values — no lookup table.
// enum ZalgoPreset {
//   faint('Faint', 0.10, 0.0, 0.10),
//   uneasy('Uneasy', 0.25, 0.0, 0.25),
//   haunted('Haunted', 0.45, 0.0, 0.40),
//   cursed('Cursed', 0.70, 0.0, 0.55),
//   obliterated('Obliterated', 1.00, 0.0, 0.90),
//   ascending('Ascending', 0.55, 0.9, 0.20),
//   descending('Descending', 0.55, -0.9, 0.20);

//   const ZalgoPreset(this.label, this.chaos, this.balance, this.strike);

//   final String label;
//   final double chaos;
//   final double balance;
//   final double strike;
// }

class ZalgoOptions {
  const ZalgoOptions({
    this.chaos = 0.25,
    this.balance = 0.0,
    this.strike = 0.25,
    this.corruptSpaces = false,
    this.seed = 0,
  });
  
  ZalgoOptions.fromPreset(
    ZalgoPreset preset, {
    this.seed = 0,
    this.corruptSpaces = false,
  }) : chaos = preset.chaos,
       balance = preset.balance,
       strike = preset.strike;

  /// 0–1. How many marks pile onto each character.
  final double chaos;

  /// -1 (all below) … 0 (even) … +1 (all above).
  final double balance;

  /// 0–1. Weight of the through-the-letter band.
  final double strike;
  final bool corruptSpaces;
  final int seed;
  static const int _maxStack = 30;
  static const int _maxStrike = 10;
  int get aboveCount => (_maxStack * chaos * _aboveWeight).round();
  int get belowCount => (_maxStack * chaos * _belowWeight).round();
  int get strikeCount => (_maxStrike * strike).round();
  double get _aboveWeight => balance >= 0 ? 1.0 : 1.0 + balance;
  double get _belowWeight => balance <= 0 ? 1.0 : 1.0 - balance;

  /// Line height that stops tall stacks being clipped by the line box.
  double get lineHeight => 1.3 + chaos * 3.4;

  /// Which preset (if any) these values currently sit on.
  ZalgoPreset? matchingPreset(List<ZalgoPreset> presets) {
    for (final ZalgoPreset preset in presets) {
      if ((preset.chaos - chaos).abs() < 0.005 &&
          (preset.balance - balance).abs() < 0.005 &&
          (preset.strike - strike).abs() < 0.005) {
        return preset;
      }
    }
    return null;
  }

  ZalgoOptions copyWith({
    double? chaos,
    double? balance,
    double? strike,
    bool? corruptSpaces,
    int? seed,
  }) {
    return ZalgoOptions(
      chaos: chaos ?? this.chaos,
      balance: balance ?? this.balance,
      strike: strike ?? this.strike,
      corruptSpaces: corruptSpaces ?? this.corruptSpaces,
      seed: seed ?? this.seed,
    );
  }
}

/// Corrupts [input]. Deterministic for a given input and options.
String zalgoify(String input, ZalgoOptions options) {
  if (input.isEmpty) return '';
  
  final Random rng = Random(options.seed);
  final StringBuffer buffer = StringBuffer();
  final int above = options.aboveCount;
  final int strike = options.strikeCount;
  final int below = options.belowCount;

  for (final String grapheme in input.characters) {
    buffer.write(grapheme);
    
    if (grapheme == '\n' || grapheme == '\r') continue;
    if (!options.corruptSpaces && grapheme.trim().isEmpty) continue;
    
    _spray(buffer, rng, _above, above);
    _spray(buffer, rng, _middle, strike);
    _spray(buffer, rng, _below, below);
  }
  return buffer.toString();
}

final RegExp _combiningMarks = RegExp(
  r'[\u0300-\u036f\u0483-\u0489\u1ab0-\u1aff\u1dc0-\u1dff\u20d0-\u20f0\ufe20-\ufe2f]',
);

/// Removes every combining mark — undoes Zalgo, and cleans pasted-in text.
String stripZalgo(String input) => input.replaceAll(_combiningMarks, '');
void _spray(
  StringBuffer buffer,
  Random rng,
  List<String> marks,
  int intensity,
) {
  if (intensity <= 0) return;
  
  final int count = 1 + rng.nextInt(intensity);
  
  for (int i = 0; i < count; i++) {
    buffer.write(marks[rng.nextInt(marks.length)]);
  }
}
