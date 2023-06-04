import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman/classes/player_class.dart';

class PlayerPainter extends CustomPaint with ChangeNotifier {
  late Player player;
  double animation = 0;

  void _drawSpeenWheel(Canvas canvas, Paint paint,
      {Offset? center,
      double? radius,
      List<double>? sources,
      List<Color>? colors,
      double? strtRadian}) {
    var total = 0.0;
    for (var d in sources!) {
      total += d;
    }
    List<double> radians = [];
    for (var data in sources) {
      radians.add(data * 2 * pi / total);
    }
    for (var i = 0; i < radians.length; i++) {
      paint.color = colors![i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center!, radius: radius!),
          strtRadian!, radians[i], true, paint);
      strtRadian += radians[i];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width * 0.75 / 2, size.height * 0.75 / 2);

    Path path = Path();
    if (player.die) {
      _drawSpeenWheel(
        canvas,
        paint,
        sources: [animation, 3],
        colors: [Colors.transparent, const Color.fromARGB(255, 252, 228, 19)],
        center: center,
        radius: radius,
        strtRadian: 3.1 - animation * 0.8,
      );
    }
  }

  PlayerPainter(this.player, this.animation);
  SetBase(Player player) {
    this.player = player;
  }

  @override
  bool shouldRepaint(covariant CustomPaint oldDelegate) => true;

  void _drawDie(Canvas canvas, Paint paint, {double? radius, Offset? center}) {
    paint.color = const Color.fromARGB(255, 252, 228, 19);
    canvas.drawCircle(center!, radius! * (1 - animation), paint);
  }
}
