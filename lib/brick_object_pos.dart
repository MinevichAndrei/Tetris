import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/brick_shape_enum.dart';
import 'package:tetris/brick_shape_static.dart';

class BrickObjectPos {
  Offset offset;
  BrickShapeEnum shapeEnum;
  int rotation;
  bool isDone;
  Size? sizeLayout;
  Size? size;
  List<int> pointArray = [];
  Color color;

  static clone(BrickObjectPos object) {
    return BrickObjectPos(
      offset: object.offset,
      shapeEnum: object.shapeEnum,
      rotation: object.rotation,
      isDone: object.isDone,
      sizeLayout: object.sizeLayout,
      color: object.color,
    );
  }

  BrickObjectPos({
    this.size,
    this.sizeLayout,
    this.isDone = false,
    this.offset = Offset.zero,
    this.shapeEnum = BrickShapeEnum.line,
    this.rotation = 0,
    this.color = Colors.amber,
  }) {
    calculateHit();
  }

  setShape(BrickShapeEnum shapeEnum) {
    this.shapeEnum = shapeEnum;
    calculateHit();
  }

  calculateRotation(int flag) {
    rotation += flag;
    calculateHit();
  }

  calculateHit({Offset? predict}) {
    List<int> lists =
        BrickShapeStatic.getListBrickOnEnum(shapeEnum, direction: rotation)
            .expand((element) => element)
            .map((e) => e.toInt())
            .toList();
    List<int> tempPoint = lists
        .asMap()
        .entries
        .map((e) => calculateOffset(e, lists.length, predict ?? offset))
        .toList();
    if (predict != null) {
      return tempPoint;
    } else {
      return pointArray = tempPoint;
    }
  }

  int calculateOffset(MapEntry<int, int> entry, int length, Offset offsetTemp) {
    int value = entry.value;

    if (size != null) {
      if (value == 0) {
        value = -99999;
      } else {
        double left = offsetTemp.dx / size!.width + entry.key % sqrt(length);
        double top = offsetTemp.dy / size!.height + entry.key ~/ sqrt(length);

        int index =
            left.toInt() + (top * (sizeLayout!.width / size!.width)).toInt();

        value = (index).toInt();
      }
    }

    return value;
  }
}
