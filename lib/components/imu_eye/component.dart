import 'dart:math';

import 'package:flutter/material.dart';

import '../../utilities/zalgo.dart';

final RegExp _imuName = RegExp(r'\bimu\b', caseSensitive: false);

/// Whether [text] names Imu ("Imu", "Imu sama", "Imu-sama", …). Existing
/// zalgo marks are stripped first, so corrupted text still counts.
bool summonsImu(String text) => _imuName.hasMatch(stripZalgo(text));

const Color _void = Color(0xFF000000);
const Color _crimson = Color(0xFFD00000);
const Color _ember = Color(0xFFFF4A3D);
const Color _sclera = Color(0xFFEFE4D2);
const Color _bloodshot = Color(0xFFB0504A);

/// Imu's ringed eye staring out of the dark. Opens while [visible] is true,
/// with the iris breathing and the glow flickering, and snaps shut when it
/// goes false. Paints nothing at all once it is fully closed.
class ImuEye extends StatefulWidget {
  const ImuEye({super.key, required this.visible});

  final bool visible;  // <-- true while the text names Imu

  @override
  State<ImuEye> createState() => _ImuEyeState();
}

class _ImuEyeState extends State<ImuEye> with TickerProviderStateMixin {
  late final AnimationController _open;
  late final AnimationController _pulse;
  late final CurvedAnimation _lid;

  @override
  void initState() {
    super.initState();

    _open = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),        // opening
      reverseDuration: const Duration(milliseconds: 450), // shutting, twice as fast
    )..addStatusListener((AnimationStatus status) {
      // Fully shut: nothing is on screen, so stop burning frames on the pulse.
      if (status == AnimationStatus.dismissed) _pulse.stop();
    });

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // easeOutBack overshoots past 1 on the way open, which snaps the lid wide.
    // The reverse curve must not do that: dipping below 0 would make the eye
    // vanish a frame early instead of closing all the way.
    _lid = CurvedAnimation(
      parent: _open,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    if (widget.visible) _openEye();
  }

  @override
  void didUpdateWidget(ImuEye oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;

    // Both start from the lid's current position, so backspacing mid-open
    // reverses from there instead of jumping.
    widget.visible ? _openEye() : _open.reverse();
  }

  void _openEye() {
    _pulse.repeat(reverse: true);
    _open.forward();
  }

  @override
  void dispose() {
    _lid.dispose();
    _open.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_lid, _pulse]),
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ImuEyePainter(open: _lid.value, pulse: _pulse.value),
        );
      },
    );
  }
}

class _ImuEyePainter extends CustomPainter {
  _ImuEyePainter({required this.open, required this.pulse});

  /// 0 (shut) … 1 (open). Overshoots a little as the lid snaps wide.
  final double open;

  /// 0–1, back and forth.
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    // Shut: Imu is gone, so leave the panel alone entirely.
    if (open <= 0) return;

    final Rect bounds = Offset.zero & size;
    final Offset center = bounds.center;

    // The shadow Imu always hides in. It lifts with the lid, so closing the
    // eye doesn't leave the preview darkened.
    final double veil = open.clamp(0.0, 1.0);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          radius: 0.9,
          colors: <Color>[
            _void.withValues(alpha: 0.9 * veil),
            _void.withValues(alpha: 0.6 * veil),
            _void.withValues(alpha: 0),
          ],
          stops: const <double>[0, 0.5, 1],
        ).createShader(bounds),
    );

    final double width = min(size.width, size.height * 1.8) * 0.75;
    final double fullHeight = width * 0.42;
    final double height = fullHeight * open;
    if (width <= 0 || height <= 0.5) return;

    // Quadratic curves peak halfway to their control point, so the opening
    // is [height] tall in total.
    final Path almond = Path()
      ..moveTo(center.dx - width / 2, center.dy)
      ..quadraticBezierTo(
        center.dx,
        center.dy - height,
        center.dx + width / 2,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + height,
        center.dx - width / 2,
        center.dy,
      )
      ..close();

    canvas.drawPath(
      almond,
      Paint()
        ..color = _crimson.withValues(alpha: 0.5 + 0.4 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 + 16 * pulse),
    );

    canvas.save();
    canvas.clipPath(almond);

    canvas.drawPath(
      almond,
      Paint()
        ..shader = RadialGradient(
          radius: 1.3,
          colors: const <Color>[_sclera, _sclera, _bloodshot],
          stops: const <double>[0, 0.45, 1],
        ).createShader(
          Rect.fromCenter(center: center, width: width, height: fullHeight),
        ),
    );

    final double iris = fullHeight * 0.4 * (0.96 + 0.08 * pulse);
    _paintVeins(canvas, center, iris, width);
    _paintIris(canvas, center, iris);

    canvas.restore();

    canvas.drawPath(
      almond,
      Paint()
        ..color = _void
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(3, width * 0.018)
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintVeins(Canvas canvas, Offset center, double iris, double width) {
    // Fixed seed: the same veins every frame instead of a flickering mess.
    final Random rng = Random(7);
    final Paint vein = Paint()
      ..color = _crimson.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const int count = 22;
    for (int i = 0; i < count; i++) {
      final double angle = 2 * pi * i / count + rng.nextDouble() * 0.3;
      final double length = width * (0.12 + rng.nextDouble() * 0.2);
      Offset point = center + Offset.fromDirection(angle, iris);
      final Path path = Path()..moveTo(point.dx, point.dy);
      for (int step = 1; step <= 4; step++) {
        final double wobble = (rng.nextDouble() - 0.5) * 0.25;
        point =
            center +
            Offset.fromDirection(angle + wobble, iris + length * step / 4);
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, vein);
    }
  }

  void _paintIris(Canvas canvas, Offset center, double iris) {
    canvas.drawCircle(center, iris, Paint()..color = _void);

    // Rings within rings, alternating crimson and ember over black.
    const int rings = 6;
    final double spacing = iris / (rings + 1);
    for (int i = 0; i < rings; i++) {
      canvas.drawCircle(
        center,
        iris - spacing * (i + 0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = spacing * 0.55
          ..color = i.isEven
              ? _crimson
              : _ember.withValues(alpha: 0.55 + 0.45 * pulse),
      );
    }

    canvas.drawCircle(
      center,
      iris,
      Paint()
        ..color = _void
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(2, iris * 0.06),
    );

    // A pinprick pupil in a glowing core is what makes it look unhinged.
    canvas.drawCircle(center, spacing * 1.1, Paint()..color = _ember);
    canvas.drawCircle(center, spacing * 0.45, Paint()..color = _void);
    canvas.drawCircle(
      center + Offset(-iris * 0.35, -iris * 0.35),
      iris * 0.07,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_ImuEyePainter oldDelegate) =>
      oldDelegate.open != open || oldDelegate.pulse != pulse;
}
