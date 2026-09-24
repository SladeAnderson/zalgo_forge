/// Named points in the option space. Dart 3 enhanced enums carry fields, so
/// a preset *is* its values — no lookup table.
class ZalgoPreset {
  const ZalgoPreset(this.id,this.label, this.chaos, this.balance, this.strike);

  final String id;
  final String label;
  final double chaos;
  final double balance;
  final double strike;

  static const ZalgoPreset faint = ZalgoPreset('faint01','Faint', 0.10, 0.0, 0.10);
  static const ZalgoPreset uneasy = ZalgoPreset('uneasy01','Uneasy', 0.25, 0.0, 0.25);
  static const ZalgoPreset haunted = ZalgoPreset('haunted01','Haunted', 0.45, 0.0, 0.40);
  static const ZalgoPreset cursed = ZalgoPreset('cursed01','Cursed', 0.70, 0.0, 0.55);
  static const ZalgoPreset obliterated = ZalgoPreset('obliterated01','Obliterated', 1.00, 0.0, 0.90);
  static const ZalgoPreset ascending = ZalgoPreset('ascending01','Ascending', 0.55, 0.9, 0.20);
  static const ZalgoPreset descending = ZalgoPreset('descending01','Descending', 0.55, -0.9, 0.20);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'label': label,
    'chaos': chaos,
    'balance': balance,
    'strike': strike,
  };

  factory ZalgoPreset.fromJson(Map<String, dynamic> json) => ZalgoPreset(
    json['id'] as String,
    json['label'] as String,
    (json['chaos'] as num).toDouble(),
    (json['balance'] as num).toDouble(),
    (json['strike'] as num).toDouble()
  );

  static const List<ZalgoPreset> builtIns = <ZalgoPreset>[faint, uneasy, haunted, cursed, obliterated, ascending, descending];
}