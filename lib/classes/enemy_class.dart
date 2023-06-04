import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman/classes/boxPos_class.dart';
import 'package:pacman/classes/box_class.dart';
import 'package:pacman/classes/row_column.dart';

class Enemy {
  bool start = false;
  bool roaming = false;
  bool die = false;
  bool pause = false;
  BoxPos? position;
  List<Offset> targetOffsets = [];
  Offset? targetOffset;
  int? randomDelay;

  bool returnBase = false;

  Enemy({this.position, Offset? offset}) {
    position ??= BoxPos(0, 0);
    if (offset != null) setOffset(offset);
  }
  void setOffset(Offset offset) {
    position!.setOffset(offset);
  }

  void setStart(bool start) => this.start = start;
  void setRoaming(bool roaming) => this.roaming = roaming;

  bool FlagMove() {
    return start;
  }

  void setPlay() {
    start = true;
    pause = false;
  }

  void setPause() {
    pause = true;
  }

  void setReset({bool dieEvent = false, bool setDefaultPos = true}) {
    pause = false;
    if (!dieEvent) {
      die = false;
      start = false;
      returnBase = false;
      if (setDefaultPos) position!.setOffset(position!.defaultPos!);
    } else {
      die = true;
      start = true;
      returnBase = true;
      randomDelay = null;
    }
    playerPowerUp = false;
    targetOffsets = [];
    targetOffset = null;
  }

  void setReturn(bool returnBase) => this.returnBase = returnBase;

  void gotPowerUp() {
    if (returnBase || die) return;
    playerPowerUp = true;
    targetOffsets = [];
    targetOffset = null;
    randomDelay = 0;
    calculateNextTarget();
  }

  void cancelPowerUp() {
    if (returnBase || die) return;
    playerPowerUp = true;
    targetOffsets = [];
    targetOffset = null;
    randomDelay = 0;
    calculateNextTarget();
  }

  bool completeArrive(Size size) {
    if (targetOffset == null) return false;
    return (targetOffset! - position!.offset!).distance <
        (size.shortestSide * 0.25);
  }

  void calculateNextTarget() {
    if (targetOffsets.length <= randomDelay! && !returnBase) {
      targetOffsets = [];
      generateRandom();
    }

    if (targetOffsets.isEmpty) return;
    targetOffset = targetOffsets.removeAt(0);

    position!.setDirectionInt(targetOffset! - position!.offset!,
        canRotateRealTime: true);
  }

  void computedNewPoint(
    Offset playerOffset,
    List<Box> boxes, {
    required RowColumn boxSize,
    required List<List<dynamic>> barriers,
    required Size size,
    required int index,
  }) {
    targetOffsets = [];
    targetOffset = null;

    if (playerPowerUp) {
      List<Box> boxTargets = boxes
          .where((element) =>
              (element.position!.offset! - playerOffset).distance >
              size.shortestSide * 2)
          .toList();
      if (boxTargets.isNotEmpty) {
        boxTargets.shuffle();
        playerOffset = boxTargets.first.position!.offset!;
      }
    }

    Box? playerBox =
        boxes.firstWhere((element) => element.chackOffsetIn(playerOffset));
    Box? ghostBox =
        boxes.firstWhere((element) => element.chackOffsetIn(position!.offset!));

    Offset ghostPos = Offset(ghostBox.position!.columnIndex.toDouble(),
        ghostBox.position!.rowIndex.toDouble());
    Offset playerPos = Offset(playerBox.position!.columnIndex.toDouble(),
        playerBox.position!.rowIndex.toDouble());

    final result = AStar(
      rows: boxSize.row,
      column: boxSize.column,
      start: ghostPos,
      end: playerPos,
      barriers: List<Offset>.from(barriers.expand((element) => element)),
      withDiagonal: false,
    ).findThepath();
    targetOffsets =
        result.map((e) => e.scale(size.width, size.height)).toList();
    targetOffsets.add(playerPos);
    if (!die) {
      generateRandom();
    } else {
      randomDelay = targetOffsets.length - 1;
    }
    calculateNextTarget();
  }

  void move(Size size) {
    if (targetOffset != null && !pause) {
      position!.setOffset(position!.getOffsetBasedRotation(size));
    }
  }

  void generateRandom() {
    randomDelay =
        targetOffsets.length < 2 ? 0 : Random().nextInt(targetOffsets.length);
  }

  void setDie() {
    die = true;
  }

  void setStop() {}
  getColor(int index) {
    late Color color;
    if (playerPowerUp) {
      color = const Color.fromARGB(255, 2, 70, 126);
    } else {
      switch (index) {
        case 0:
          color = Colors.red;
          break;
        case 1:
          color = Colors.blue;
          break;
        case 2:
          color = Colors.orange;
          break;
        default:
          color = Colors.pink;
      }
    }
    return color;
  }
}
