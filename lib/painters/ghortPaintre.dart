import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman/classes/box_class.dart';
import 'package:pacman/classes/enemy_class.dart';

class GhostPainter extends CustomPaint with ChangeNotifier {
  late Enemy enemy;
  late int index;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Path pathEyes = Path();

    pathEyes.addOval(Rect.fromCircle(
        center: getOffsetBasePercent(size, 0.35, 0.4),
        radius: size.width * 0.15));
    pathEyes.addOval(Rect.fromCircle(
        center: getOffsetBasePercent(size, 0.65, 0.4),
        radius: size.width * 0.15));

    Color color = enemy.getColor(index);
    if (!enemy.die) {
      path.addPolygon([
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.2, 0.2),
      ], true);
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill
            ..strokeWidth = 3);
    }
    canvas.drawPath(
        pathEyes,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
          ..strokeWidth = 3);
    canvas.drawPath(
        makeEyelid(canvas, enemy, size),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
          ..strokeWidth = 3);
  }

  GhostPainter(this.index, this.enemy);

  setBoxes(Enemy enemy) {
    this.enemy = enemy;
  }

  @override
  bool shouldRepaint(covariant CustomPaint oldDelegate) => true;

  Offset getOffsetBasePercent(Size size, double d, double e) {
    return Offset(size.width * d, size.height * e);
  }

  Path makeEyelid(Canvas canvas, Enemy enemy, Size size) {
    Path pathEyeBlacks = Path();

    for (var element in [const Size(0.35, 0.4), const Size(0.65, 0.4)]) {
      pathEyeBlacks.addOval(Rect.fromCircle(
          center:
              eyeLidDirection(enemy.position!.direction, size, element, 0.08),
          radius: size.width * 0.08));
    }
    return pathEyeBlacks;
  }

  Offset eyeLidDirection(
      Direction direction, Size size, Size sizePos, double distance) {
    Offset offset = Offset.zero;
    switch (direction) {
      case Direction.Right:
        offset = offset.translate(size.shortestSide * distance, 0);
        break;
      case Direction.Left:
        offset = offset.translate(-(size.shortestSide * distance), 0);
        break;
      case Direction.Bottom:
        offset = offset.translate(0, size.shortestSide * distance);
        break;
      default:
        offset = offset.translate(0, -(size.shortestSide * distance));
    }
    return getOffsetBasePercent(size, sizePos.width, sizePos.height)
        .translate(offset.dx, offset.dy);
  }
}
