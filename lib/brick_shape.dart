import 'package:flutter/material.dart';

class BrickShape extends StatefulWidget {
  final List<List<double>> list;
  final List? points;
  final double sizePerSquare;
  final Color? color;

  BrickShape(this.list,
      {Key? key, this.color, this.points, this.sizePerSquare = 20})
      : super(key: key);

  @override
  _BrickShapeState createState() => _BrickShapeState();
}

class _BrickShapeState extends State<BrickShape> {
  @override
  Widget build(BuildContext context) {
    int totalPointList = (widget.list.expand((element) => element).length);
    int columnNum = (totalPointList ~/ widget.list.length);
    return Container(
      width: widget.sizePerSquare * columnNum,
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: totalPointList,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnNum,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return Offstage(
              offstage:
                  widget.list.expand((element) => element).toList()[index] == 0,
              child: boxBrick(widget.color ?? Colors.cyan,
                  text: widget.points?[index] ?? ''),
            );
          }),
    );
  }
}

Widget boxBrick(Color color, {text = ""}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(color: color, border: Border.all(width: 1)),
  );
}
