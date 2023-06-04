import 'package:flutter/material.dart';

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

  bool CheckDirectionAxis(Direction direction, List<Direction> directions) =>
      directions.where((element) => element == direction).isNotEmpty;

  bool CheckOffsetInRange(Offset playerPos) {
    Offset boxPosMin =
        position!.offset!.translate(size.width / 10 * 3, size.height / 10 * 3);
    Offset boxPosMax =
        position!.offset!.translate(size.width / 10 * 7, size.height / 10 * 7);

    return (boxPosMin.dx <= playerPos.dx &&
        boxPosMax.dx >= playerPos.dx &&
        boxPosMin.dy <= playerPos.dy &&
        boxPosMax.dy >= playerPos.dy);
  }
}
