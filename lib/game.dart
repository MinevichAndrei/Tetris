import 'package:flutter/material.dart';
import 'package:tetris/brick_object_pos.dart';
import 'package:tetris/brick_shape.dart';
import 'package:tetris/brick_shape_enum.dart';
import 'package:tetris/brick_shape_static.dart';
import 'package:tetris/tetris_widget.dart';

class TetrisGame extends StatefulWidget {
  const TetrisGame({Key? key}) : super(key: key);

  @override
  _TetrisGameState createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  GlobalKey<TetrisWidgetState> keyGlobal = GlobalKey();
  ValueNotifier<List<BrickObjectPos>> brickObjectPosValue =
      ValueNotifier<List<BrickObjectPos>>(List<BrickObjectPos>.from([]));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double sizePerSquare = 40;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.blue),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: constraints.biggest.width / 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Scores: ${0}"),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Scores: ${0}"),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.red.shade900)),
                                onPressed: () {
                                  keyGlobal.currentState!.resetGame();
                                },
                                child: Text("Reset"),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.red.shade900)),
                                onPressed: () {
                                  keyGlobal.currentState!.pauseGame();
                                },
                                child: Text("Pause"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: constraints.biggest.width / 2,
                      decoration: BoxDecoration(color: Colors.yellow),
                      child: Column(
                        children: [
                          Text("Next : "),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            child: ValueListenableBuilder(
                                valueListenable: brickObjectPosValue,
                                builder: (context, List<BrickObjectPos> value,
                                    child) {
                                  BrickShapeEnum tempShapeEnum =
                                      value.isNotEmpty
                                          ? value.last.shapeEnum
                                          : BrickShapeEnum.lShape;
                                  int rotation = value.isNotEmpty
                                      ? value.last.rotation
                                      : 0;
                                  return BrickShape(
                                      BrickShapeStatic.getListBrickOnEnum(
                                          tempShapeEnum,
                                          direction: rotation));
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    decoration: BoxDecoration(color: Colors.green),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return TetrisWidget(constraints.biggest,
                            key: keyGlobal,
                            sizePerSquare: sizePerSquare, setNextBrick:
                                (List<BrickObjectPos> brickObjectPos) {
                          brickObjectPosValue.value = brickObjectPos;
                          brickObjectPosValue.notifyListeners();
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.red),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => keyGlobal.currentState!
                            .transformBrick(Offset(-sizePerSquare, 0), false),
                        child: Text("Left"),
                      ),
                      ElevatedButton(
                        onPressed: () => keyGlobal.currentState!
                            .transformBrick(Offset(sizePerSquare, 0), false),
                        child: Text("Right"),
                      ),
                      ElevatedButton(
                        onPressed: () => keyGlobal.currentState!
                            .transformBrick(Offset(0, sizePerSquare), false),
                        child: Text("Bottom"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            keyGlobal.currentState!.transformBrick(null, true),
                        child: Text("Rotate"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
