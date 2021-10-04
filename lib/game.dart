import 'package:flutter/material.dart';

class TetrisGame extends StatefulWidget {
  const TetrisGame({Key? key}) : super(key: key);

  @override
  _TetrisGameState createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
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
                                onPressed: () {},
                                child: Text("Reset"),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.red.shade900)),
                                onPressed: () {},
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
                            child: Container(),
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
                    child: Container(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.red),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Left"),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Right"),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Bottom"),
                      ),
                      ElevatedButton(
                        onPressed: () {},
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