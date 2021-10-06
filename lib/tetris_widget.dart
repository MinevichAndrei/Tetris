import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/brick_object_pos.dart';
import 'package:tetris/brick_object_pos_done.dart';
import 'package:tetris/brick_shape.dart';
import 'package:tetris/brick_shape_enum.dart';
import 'package:tetris/brick_shape_static.dart';

class TetrisWidget extends StatefulWidget {
  final Size size;
  final double? sizePerSquare;
  Function(List<BrickObjectPos> brickObjectPos)? setNextBrick;
  TetrisWidget(this.size, {Key? key, this.setNextBrick, this.sizePerSquare})
      : super(key: key);

  @override
  TetrisWidgetState createState() => TetrisWidgetState();
}

class TetrisWidgetState extends State<TetrisWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  late Size sizeBox;
  late List<int> levelBases;
  ValueNotifier<List<BrickObjectPos>> brickObjectPosValue =
      ValueNotifier<List<BrickObjectPos>>([]);

  ValueNotifier<List<BrickObjectPosDone>> donePointsValue =
      ValueNotifier<List<BrickObjectPosDone>>([]);

  ValueNotifier<int> animationPosTickValue = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    calculateSizeBox();
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animation = Tween<double>(begin: 0, end: 1).animate(animationController)
      ..addListener(animationLoop);
    animationController.forward();
  }

  calculateSizeBox() {
    sizeBox = Size(
      (widget.size.width ~/ widget.sizePerSquare!) * widget.sizePerSquare!,
      (widget.size.height ~/ widget.sizePerSquare!) * widget.sizePerSquare!,
    );

    levelBases = List.generate(sizeBox.width ~/ widget.sizePerSquare!, (index) {
      return (((sizeBox.height ~/ widget.sizePerSquare!) - 1) *
              (sizeBox.width ~/ widget.sizePerSquare!)) +
          index;
    });

    levelBases
        .addAll(List.generate(sizeBox.height ~/ widget.sizePerSquare!, (index) {
      return index * (sizeBox.width ~/ widget.sizePerSquare!);
    }));

    levelBases
        .addAll(List.generate(sizeBox.height ~/ widget.sizePerSquare!, (index) {
      return (index * (sizeBox.width ~/ widget.sizePerSquare!)) +
          (sizeBox.width ~/ widget.sizePerSquare! - 1);
    }));
  }

  pauseGame() async {
    animationController.stop();
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          Text("Pause Game"),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                animationController.forward();
              },
              child: Text("Resume")),
        ],
      ),
    );
  }

  resetGame() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        children: [
          Text("Reset Game"),
          ElevatedButton(
              onPressed: () {
                donePointsValue.value = [];
                donePointsValue.notifyListeners();

                brickObjectPosValue.value = [];
                brickObjectPosValue.notifyListeners();

                Navigator.of(context).pop();

                calculateSizeBox();
                randomBrick(start: true);
                animationController.reset();
                animationController.stop();
                animationController.forward();
              },
              child: Text("Start / Reset")),
        ],
      ),
    );
  }

  animationLoop() async {
    if (animation.isCompleted && brickObjectPosValue.value.length > 1) {
      BrickObjectPos currentObj =
          brickObjectPosValue.value[brickObjectPosValue.value.length - 2];

      Offset target = currentObj.offset.translate(0, widget.sizePerSquare!);

      if (checkTargetMove(target, currentObj)) {
        currentObj.offset = target;
        currentObj.calculateHit();
        brickObjectPosValue.notifyListeners();
      } else {
        // currentObj.isDone = true;
        currentObj.pointArray
            .where((element) => element != -99999)
            .toList()
            .forEach((element) {
          donePointsValue.value
              .add(BrickObjectPosDone(element, color: currentObj.color));
        });

        donePointsValue.notifyListeners();

        brickObjectPosValue.value
            .removeAt(brickObjectPosValue.value.length - 2);
        await checkCompleteLine();
        bool status = await checkGameOver();

        if (!status) {
          randomBrick();
        } else {
          print("Game Over");
        }
      }

      animationController.reset();
      animationController.forward();
    }
  }

  Future<bool> checkGameOver() async {
    return donePointsValue.value
        .where((element) => element.index < 0 && element.index != -99999)
        .isNotEmpty;
  }

  checkCompleteLine() async {
    List<int> leftINdex =
        List.generate(sizeBox.height ~/ widget.sizePerSquare!, (index) {
      return index * ((sizeBox.width ~/ widget.sizePerSquare!));
    });

    int totalCol = (sizeBox.width ~/ widget.sizePerSquare!) - 2;

    List<int> linetoDestroys = leftINdex
        .where((element) {
          return donePointsValue.value
              .where((point) => point.index == element + 1)
              .isNotEmpty;
        })
        .where((donePoint) {
          List<int> rows =
              List.generate(totalCol, (index) => donePoint + 1 + index)
                  .toList();
          return rows.where((row) {
                return donePointsValue.value
                    .where((element) => element.index == row)
                    .isNotEmpty;
              }).length ==
              rows.length;
        })
        .map((e) {
          return List.generate(totalCol, (index) => e + 1 + index).toList();
        })
        .expand((element) => element)
        .toList();

    List<BrickObjectPosDone> tempDonePoints = donePointsValue.value;

    if (linetoDestroys.isNotEmpty) {
      linetoDestroys.sort((a, b) => a.compareTo(b));
      tempDonePoints.sort((a, b) => a.index.compareTo(b.index));

      int firstIndex = tempDonePoints
          .indexWhere((element) => element.index == linetoDestroys.first);

      if (firstIndex >= 0) {
        tempDonePoints.removeWhere((element) {
          return linetoDestroys
              .where((line) => line == element.index)
              .isNotEmpty;
        });

        donePointsValue.value = tempDonePoints.map((element) {
          if (element.index < linetoDestroys.first) {
            int totalRowDelete = linetoDestroys.length ~/ totalCol;
            element.index = element.index + ((totalCol + 2) * totalRowDelete);
          }
          return element;
        }).toList();

        donePointsValue.notifyListeners();
      }
    }
  }

  bool checkTargetMove(Offset targetPos, BrickObjectPos object) {
    List<int> pointsPredict = object.calculateHit(predict: targetPos);
    List<int> hitsIndex = [];
    hitsIndex.addAll(levelBases);

    hitsIndex.addAll(donePointsValue.value.map((e) => e.index));

    int numberHitBase = pointsPredict
        .map((e) => hitsIndex.indexWhere((element) => element == e) > -1)
        .where((element) => element)
        .length;
    return numberHitBase == 0;
  }

  randomBrick({start = false}) {
    brickObjectPosValue.value.add(getNewBrickPos());
    if (start) {
      brickObjectPosValue.value.add(getNewBrickPos());
    }

    widget.setNextBrick!.call(brickObjectPosValue.value);
    brickObjectPosValue.notifyListeners();
  }

  BrickObjectPos getNewBrickPos() {
    return BrickObjectPos(
      size: Size.square(widget.sizePerSquare!),
      sizeLayout: sizeBox,
      color:
          Colors.primaries[Random().nextInt(Colors.primaries.length)].shade800,
      rotation: Random().nextInt(4),
      offset: Offset(widget.sizePerSquare! * 4, -widget.sizePerSquare! * 3),
      shapeEnum:
          BrickShapeEnum.values[Random().nextInt(BrickShapeEnum.values.length)],
    );
  }

  @override
  void dispose() {
    animation.removeListener(animationLoop);
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.brown),
      child: Container(
        width: sizeBox.width,
        height: sizeBox.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white),
        child: ValueListenableBuilder(
          valueListenable: donePointsValue,
          builder: (context, List<BrickObjectPosDone> donePoints, child) {
            return ValueListenableBuilder(
                valueListenable: brickObjectPosValue,
                builder:
                    (context, List<BrickObjectPos> brickObjectPoses, child) {
                  return Stack(
                    children: [
                      ...List.generate(
                          sizeBox.width ~/
                              widget.sizePerSquare! *
                              sizeBox.height ~/
                              widget.sizePerSquare!, (index) {
                        return Positioned(
                          left: index %
                              (sizeBox.width / widget.sizePerSquare!) *
                              widget.sizePerSquare!,
                          top: index ~/
                              (sizeBox.width / widget.sizePerSquare!) *
                              widget.sizePerSquare!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: checkIndexHitBase(index)
                                  ? Colors.black87
                                  : Colors.transparent,
                              border: Border.all(width: 1),
                            ),
                            width: widget.sizePerSquare!,
                            height: widget.sizePerSquare!,
                          ),
                        );
                      }).toList(),
                      if (brickObjectPoses.length > 1)
                        ...brickObjectPoses
                            .where((element) => !element.isDone)
                            .toList()
                            .asMap()
                            .entries
                            .map(
                              (e) => Positioned(
                                left: e.value.offset.dx,
                                top: e.value.offset.dy,
                                child: BrickShape(
                                  BrickShapeStatic.getListBrickOnEnum(
                                    e.value.shapeEnum,
                                    direction: e.value.rotation,
                                  ),
                                  sizePerSquare: widget.sizePerSquare!,
                                  points: e.value.pointArray,
                                  color: e.value.color,
                                ),
                              ),
                            )
                            .toList(),
                      if (donePoints.isNotEmpty)
                        ...donePoints.map(
                          (e) => Positioned(
                            left: e.index %
                                (sizeBox.width / widget.sizePerSquare!) *
                                widget.sizePerSquare!,
                            top: (e.index ~/
                                (sizeBox.width / widget.sizePerSquare!) *
                                widget.sizePerSquare!),
                            child: Container(
                              width: widget.sizePerSquare,
                              height: widget.sizePerSquare,
                              child: boxBrick(e.color, text: e.index),
                            ),
                          ),
                        ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }

  checkIndexHitBase(int index) {
    return levelBases.indexWhere((element) => element == index) != -1;
  }

  transformBrick(Offset? move, bool? rotate) {
    if (move != null || rotate != null) {
      late Offset target;
      BrickObjectPos currentObj =
          brickObjectPosValue.value[brickObjectPosValue.value.length - 2];
      if (move != null) {
        target = currentObj.offset.translate(move.dx, move.dy);
        if (checkTargetMove(target, currentObj)) {
          currentObj.offset = target;
          currentObj.calculateHit();
          brickObjectPosValue.notifyListeners();
        }
      } else {
        currentObj.calculateRotation(1);

        if (checkTargetMove(currentObj.offset, currentObj)) {
          currentObj.calculateHit();
          brickObjectPosValue.notifyListeners();
        } else {
          currentObj.calculateRotation(-1);
        }
      }
    }
  }
}
