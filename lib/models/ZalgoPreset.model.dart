/// Named points in the option space. Dart 3 enhanced enums carry fields, so
/// a preset *is* its values — no lookup table.
class ZalgoPreset {
  const ZalgoPreset(this.label, this.chaos, this.balance, this.strike);

  final String label;
  final double chaos;
  final double balance;
  final double strike;

  static const ZalgoPreset faint = ZalgoPreset('Faint', 0.10, 0.0, 0.10);
  static const ZalgoPreset uneasy = ZalgoPreset('Uneasy', 0.25, 0.0, 0.25);
  static const ZalgoPreset haunted = ZalgoPreset('Haunted', 0.45, 0.0, 0.40);
  static const ZalgoPreset cursed = ZalgoPreset('Cursed', 0.70, 0.0, 0.55);
  static const ZalgoPreset obliterated = ZalgoPreset('obliterated', 1.00, 0.0, 0.90);
  static const ZalgoPreset ascending = ZalgoPreset('ascending', 0.55, 0.9, 0.20);
  static const ZalgoPreset descending = ZalgoPreset('Descending', 0.55, -0.9, 0.20);


  static const List<ZalgoPreset> builtIns = <ZalgoPreset>[faint, uneasy, haunted, cursed, obliterated, ascending, descending];
}