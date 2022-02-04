import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Color myBackgroundBlue = Color(0xFF4047F0);
Color myBackgroundGrey = Color(0xFFF6F6F6);
Color myTextBlue = Color(0xFF4C79EB);
Color myTextRed = Color(0xFFDE5050);
Color myTextGrey = Color(0xFF383838);
Color myKeyboardBorder = Color(0xFFC4C4C4);


class App extends StatefulWidget {

  final double height;
  final double width;
  final double bottomPadding;

  const App(this.height, this.width, this.bottomPadding, {Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {

  TextEditingController textEditingController = TextEditingController();
  AnimationController? controller;
  AnimationController? resultController;

  double tS = 30;
  double textSize = 30;
  double rTS = 36;
  double resultTextSize = 36;

  Curve curve = Curves.easeIn;

  Animation<double>? heightTween;
  Animation<double>? widthTween;

  Offset? start;
  double startFactor = 1;
  double doneYet = 1;


  bool historyOpen = false;
  Offset? resultStart;  
  Animation<double>? resultHeightTween;

  bool keyboardInverted = false;

  bool get isSimpleKeyboard => controller?.value == 0;

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    resultController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    heightTween = Tween<double>(begin: 0.625 * widget.height + widget.bottomPadding,
                                                      end: (0.625 * widget.height + widget.bottomPadding) * 5/7).animate(CurvedAnimation(parent: controller!, curve: curve));
  
    widthTween = Tween<double>(begin: widget.width, end: widget.width * 0.8).animate(CurvedAnimation(parent: controller!, curve: curve));
    resultHeightTween = Tween<double>(begin: 0.375, end: 1).animate(resultController!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 4;

    print("height: ${widget.height}");
    print("width: ${widget.width}");
    print("bottom: ${widget.bottomPadding}");

    return Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: widget.height * 0.625,
              child: GestureDetector(
              
                onPanDown: (d) {
                        controller!.stop();
                        start = d.globalPosition;
                      },
                      onPanUpdate: (d) {
                        Offset delta = d.globalPosition - start!;
              
                        var size = MediaQuery.of(context).size;
                        double total = 1.5 * (Offset(0, size.height * 0.375) - Offset(size.width * 0.2, size.height - (size.height - (size.height * 0.625 * 5 / 7)))).distance;
              
                        double wayUp = total * controller!.value;
                        double wayDown = total * (1 - controller!.value);
              
                        // move keyboard down
                        if (controller!.value < 1 && pi / 12 <=  delta.direction && delta.direction <= 5*pi/12) {
                          controller!.value = delta.distance / total;
                        }
                        // move keyboard up
                        else if (controller!.value > 0 && -7 * pi / 12 >=  delta.direction && delta.direction >= -11 * pi/12 ) {
                          controller!.value = 1- delta.distance / total;
                        }
                      },
              
                      onPanEnd: (d) {
                        if (controller!.value > 0.5) {
                          controller!.forward();
                        } else {
                          controller!.reverse();
                        }
          
                        if (controller!.value == 1 && d.velocity.pixelsPerSecond.distanceSquared > 5 && (d.velocity.pixelsPerSecond.direction.abs() < pi / 12 || d.velocity.pixelsPerSecond.direction.abs() > 11 * pi / 12)) {
                          setState(() {
                            keyboardInverted = !keyboardInverted;
                          });
                        }
                      },
                child: Stack(
                  children: [
                    Container(
                      color: Color(0xFFF6F6F6),
                      width: size * 4,
                      child: Keyboard(textSize: textSize, columns: 5, rows: 7, keyboard: keyboardInverted ? 
                      [
                        "ln", "sin", "cos", "tan", "cot",
                        "lg", "sinh", "cosh", "tanh", "coth",
                        "√", "", "", "", "",
                        "^", "", "", "", "",
                        "x!", "", "", "", "",
                        "π", "", "", "", "",
                        "RAD", "", "", "", "",
                      ] : 
                      [
                        "e^x", "a", "b", "c", "d",
                        "10^x", "e", "f", "g", "h",
                        "x^2", "", "", "", "",
                        "^", "", "", "", "",
                        "|x|", "", "", "", "",
                        "e", "", "", "", "",
                        "RAD", "", "", "", "",
                      ], styles: [],
                      defaultBgColor: myBackgroundGrey,
                      defaultTextColor: Colors.black54,
                      controller: textEditingController,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: AnimatedBuilder(
                        animation: controller!,
                        builder: (context, child) {
                          return Container(
                            height: heightTween!.value,
                            width: widthTween!.value,
                            color: Colors.white,
                            child: Keyboard(textSize: textSize, rows: 5, columns: 4, keyboard: [
                              "C", "<-", "( )", "+",
                              "7", "8", "9", "-",
                              "4", "5", "6", "×",
                              "1", "2", "3", "÷",
                              "%", "0", ",", "=",
                            ],
                            styles: [
                              KeyStyle(["="], Colors.white, myBackgroundBlue, overlayColor: Colors.white.withOpacity(0.3)),
                              KeyStyle(["C"], myTextRed, Colors.white, overlayColor: Colors.redAccent.withOpacity(0.3)),
                              KeyStyle(["<-", "( )", "+", "-", "%", "×", "÷"], myTextBlue, Colors.white)
                            ],controller: textEditingController,),);
                        },
                        
                        
                      ))
                  ],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: resultController!,
            builder: (context, child) {
              return SizedBox(
                height: widget.height * resultHeightTween!.value,
                child: GestureDetector(
                  onVerticalDragStart: (d) {
                    resultStart = d.globalPosition;
                    historyOpen = resultController!.value == 1;
                  },
                  onVerticalDragUpdate: (d) {
                    
                  resultController!.value += d.delta.dy / widget.height;
                  },
                  onVerticalDragEnd: (d) {
                    // history opened at beginning
                    if (historyOpen) {
                      resultController!.value < 0.8 ? resultController!.reverse() : resultController!.forward();
                    } 
                    // history not opened at beginning
                    else {
                      resultController!.value > 0.2 ? resultController!.forward() : resultController!.reverse();
                    }
                     
                  },
                  
                  onScaleStart: (d) {
                      rTS = resultTextSize;
                    },
                  onScaleUpdate: (d) {
                      resultTextSize = rTS * d.scale;
                      setState(() {
                        
                      });
                    },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: resultController!.value == 0 ? null : [BoxShadow(offset: Offset(0, 1), blurRadius: 10)]

                    ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: textEditingController,
                                
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: resultTextSize, color: Colors.black,), minLines: null, maxLines: null, readOnly: true, decoration: InputDecoration(border: InputBorder.none, hintText: "0"),),
                            TextField(
                                controller: textEditingController,
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: resultTextSize, color: Colors.black.withOpacity(0.7),), minLines: null, maxLines: null, readOnly: true, decoration: InputDecoration(border: InputBorder.none),),
                            ],
                          ),
                        ),
                        Spacer(),
                        
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            child: resultController!.value == 0 ? Container(
                              key: ValueKey(1),
                            ) : Container(
                              key: ValueKey(2),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey),
                            
                                                height: 8, width: widget.width / 3)),
                        )
                      ],
                    ),
                  ),
                ),
                ),
              );
            }
          )
        ],
      
    );
  }
}

class KeyStyle {
  final List<String> text;
  final Color textColor;
  final Color bgColor;
  final Color? overlayColor;

  KeyStyle(this.text, this.textColor, this.bgColor, {this.overlayColor});
}

extension KeyStyleList on List<KeyStyle> {
  Color getTextColor(String text, Color defaultValue) {
    int index = indexWhere((element) => element.text.contains(text));
    return index > -1 ? this[index].textColor : defaultValue;
  }

  Color getBgColor(String text, Color defaultValue) {
    int index = indexWhere((element) => element.text.contains(text));
    return index > -1 ? this[index].bgColor : defaultValue;
  }

  Color? getOverlayColor(String text) {
    int index = indexWhere((element) => element.text.contains(text));
    return index > -1 ? this[index].overlayColor : null;
  }
}

class Keyboard extends StatelessWidget {

  final double textSize;
  final int rows;
  final int columns;
  final List<String> keyboard;
  final List<KeyStyle> styles;
  final Color defaultBgColor;
  final Color defaultTextColor;
  final TextEditingController controller;

  const Keyboard({Key? key, required this.textSize, required this.rows, required this.columns, required this.keyboard, required this.styles, this.defaultBgColor = Colors.white, this.defaultTextColor = Colors.black, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < rows; i++) Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int j = 0; j < columns; j++) Expanded(child: OutlinedButton(
                
                onPressed: () {
                  if (keyboard[i*columns+j] == "C") {
                    controller.clear();
                  } else {
                                      controller.text += keyboard[i*columns+j];

                  }
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(styles.getOverlayColor(keyboard[i*columns+j])),
                  backgroundColor: MaterialStateProperty.all(styles.getBgColor(keyboard[i*columns+j], defaultBgColor)),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero))),
                  side: MaterialStateProperty.all(BorderSide(color: myKeyboardBorder, width: 0.5))
                ),
                child: Center(child: AnimatedSwitcher(
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(child: child, scale: animation);
                  },
                  duration: Duration(milliseconds: 200),
                  child: Text(keyboard[i*columns+j],
                  key: ValueKey(keyboard[i*columns+j]),  
                  style: TextStyle(fontSize: textSize, color: styles.getTextColor(keyboard[i*columns+j], defaultTextColor)),),
                )))
              )],
          ),
        )
      ],
    );
  }
}
