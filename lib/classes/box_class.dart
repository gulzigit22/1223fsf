import 'package:flutter/material.dart';
import 'package:pacman/classes/boxPos_class.dart';

class Box {
  Size size;
  bool powerUp = false;
  bool gotOrange = false;
  bool isWall = false;
  bool onCheck = false;
  BoxPos? position;
  int uniqueIndex;

  Box(
    this.size, {
    this.isWall = false,
    this.gotOrange = false,
    this.powerUp = false,
    this.position,
    required this.uniqueIndex,
  });

  setOrenge(bool gotOrange) => this.gotOrange = gotOrange;
  setPowerUp(bool powerUp) => this.powerUp = powerUp;
  setIsWall(bool isWall) => this.isWall = isWall;

  void setEatOnPath() {
    setOrenge(false);
    setPowerUp(false);
  }

  bool checkDirectionAxis(Direction direction, List<Direction> directions) =>
      directions.where((element) => element == direction).isNotEmpty;

  bool checkOffsetInRange(Offset playerPos) {
    Offset boxPosMin =
        position!.offset!.translate(size.width / 10 * 3, size.height / 10 * 3);
    Offset boxPosMax =
        position!.offset!.translate(size.width / 10 * 7, size.height / 10 * 7);

    return (boxPosMin.dx <= playerPos.dx &&
        boxPosMax.dx >= playerPos.dx &&
        boxPosMin.dy <= playerPos.dy &&
        boxPosMax.dy >= playerPos.dy);
  }

  bool checkPlayerInBox(Offset playerPos, Direction direction,
      {bool test = false}) {
    Offset playerPosMax = playerPos.translate(size.width, size.height);
    Offset boxPosMin = position!.offset!;
    Offset boxPosMax = position!.offset!.translate(size.width, size.height);

    Axis axis = checkDirectionAxis(direction, [Direction.Left, Direction.Right])
        ? Axis.horizontal
        : Axis.vertical;

    bool statusCheck = false;
    switch (axis) {
      case Axis.horizontal:
        statusCheck = direction == Direction.Left
            ? (boxPosMin.dx <= playerPos.dx &&
                boxPosMax.dx >= playerPos.dx &&
                boxPosMin.dy == playerPos.dy)
            : (boxPosMin.dx <= playerPosMax.dx &&
                boxPosMax.dx >= playerPosMax.dx &&
                boxPosMin.dy == playerPos.dy);
        break;
      default:
        statusCheck = direction == Direction.Top
            ? (boxPosMin.dy <= playerPos.dy &&
                boxPosMax.dy >= playerPos.dy &&
                boxPosMin.dx == playerPos.dx)
            : (boxPosMin.dy <= playerPosMax.dy &&
                boxPosMax.dy >= playerPosMax.dy &&
                boxPosMin.dx == playerPos.dx);
    }
    return statusCheck;
  }
}

enum Direction { Left, Top, Right, Bottom }
