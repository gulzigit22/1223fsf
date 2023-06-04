import 'package:flutter/material.dart';
import 'package:pacman/classes/boxPos_class.dart';
import 'package:pacman/classes/box_class.dart';

class Player {
  BoxPos? position;
  Offset? targetOffset;
  List<Box>? boxes;
  late Size sizePerBox;
  bool start = false;
  bool die = false;
  bool powerUp = false;

  double animate = 0;
  Player({this.position}) {
    position ??= BoxPos(0, 0);
  }
  void setOffset(Offset offset) {
    position!.setOffset(offset);
    targetOffset = offset;
  }

  void setAnimate(double animate) => this.animate = animate;

  void setBoxes(List<Box> boxes) => this.boxes = boxes;

  void move(List<Box> boxess) {
    bool gotDirectionTarget = position!.gotDirectionTarget();
    bool canMoveTarget = canMove(targetCheck: true);
    if (canMoveTarget && gotDirectionTarget) {
      position!.direction = position!.directionTarget;
    }
    if (canMove())
      position!.setOffset(position!.calculateOnTargetOffset(boxess));
  }

  bool canMove({bool targetCheck = false}) {
    Offset targetOffsetTemp = position!
        .calculateOnTargetOffset(boxes, calculateOnTarget: targetCheck);
    bool pass = boxes!
        .where((element) => element.checkPlayerInBox(targetOffsetTemp,
            targetCheck ? position!.directionTarget : position!.direction,
            test: targetCheck))
        .isNotEmpty;
    return pass;
  }

  void setSize(Size sizePerBox) => this.sizePerBox = sizePerBox;

  bool flagMove() {
    return start && !die;
  }

  void setPlay() {
    start = true;
  }

  void setRaset() {
    die = false;
    start = false;
    position!.direction = Direction.Right;
    position!.directionTarget = Direction.Right;
    position!.setOffset(position!.defaultPos!);
  }

  void gorPowerUp() {
    powerUp = true;
  }

  void cancelPowerUp() {
    powerUp = false;
  }
}
