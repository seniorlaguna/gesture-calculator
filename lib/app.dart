import 'dart:math';

import 'package:calculator/calculator_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// LIGHT THEME
Color equalsBackground = const Color(0xFF4047F0);
Color equalsColor = Colors.white;
Color equalsOverlay = Colors.white.withOpacity(0.3);

Color clearAllText = const Color(0xFFDE5050);
Color clearAllOverlay = Colors.redAccent.withOpacity(0.3);

Color spacingColor = const Color(0xFFC4C4C4);

Color defaultText = Colors.black54;
Color buttonBackgroundExtended = const Color(0xffF6F6F6);
Color buttonBackgroundBase = Colors.white;

Color operatorText = const Color(0xFF4C79EB);
Color operatorBackground = Colors.white;

Color screenAndHistory = Colors.white;

Color removeHistoryItemAction = Colors.red;

Color expressionText = Colors.black;
Color resultText = Colors.grey;

Color clearHistoryText = Colors.white;
Color clearHistoryBackground = const Color(0xFF4047F0);

Color historyHandle = Colors.grey;


class App extends StatefulWidget {
  final double height;
  final double width;
  final double bottomPadding;

  const App(this.height, this.width, this.bottomPadding, {Key? key})
      : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();
  AnimationController? controller;
  AnimationController? resultController;


  final BannerAd bannerAd = BannerAd(size: AdSize.banner, adUnitId: "ca-app-pub-7519220681088057/7416942476", listener: BannerAdListener(
    onAdFailedToLoad: (ad, error) => print(error),
  ), request: const AdRequest());

  double tS = 30;
  double textSize = 24;
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

  bool useRadians = true;

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  void initState() {
    super.initState();

    bannerAd.load();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    resultController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    heightTween = Tween<double>(
            begin: 0.625 * widget.height + widget.bottomPadding,
            end: (0.625 * widget.height + widget.bottomPadding) * 5 / 7)
        .animate(CurvedAnimation(parent: controller!, curve: curve));

    widthTween = Tween<double>(begin: widget.width, end: widget.width * 0.8)
        .animate(CurvedAnimation(parent: controller!, curve: curve));
    resultHeightTween =
        Tween<double>(begin: 0.375, end: 1).animate(resultController!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 4;
/* 
    print("height: ${widget.height}");
    print("width: ${widget.width}");
    print("bottom: ${widget.bottomPadding}"); */

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
                double total = 1.5 *
                    (Offset(0, size.height * 0.375) -
                            Offset(
                                size.width * 0.2,
                                size.height -
                                    (size.height -
                                        (size.height * 0.625 * 5 / 7))))
                        .distance;

                double wayUp = total * controller!.value;
                double wayDown = total * (1 - controller!.value);

                // move keyboard down
                if (controller!.value < 1 &&
                    pi / 12 <= delta.direction &&
                    delta.direction <= 5 * pi / 12) {
                  controller!.value = delta.distance / total;
                }
                // move keyboard up
                else if (controller!.value > 0 &&
                    -7 * pi / 12 >= delta.direction &&
                    delta.direction >= -11 * pi / 12) {
                  controller!.value = 1 - delta.distance / total;
                }
              },
              onPanEnd: (d) {
                if (controller!.value > 0.5) {
                  controller!.forward();
                } else {
                  controller!.reverse();
                }

                if (controller!.value == 1 &&
                    d.velocity.pixelsPerSecond.distanceSquared > 5 &&
                    (d.velocity.pixelsPerSecond.direction.abs() < pi / 12 ||
                        d.velocity.pixelsPerSecond.direction.abs() >
                            11 * pi / 12)) {
                  setState(() {
                    keyboardInverted = !keyboardInverted;
                  });
                }
              },
              child: Stack(
                children: [
                  Container(
                    width: size * 4,
                    child: Keyboard(
                      textSize: textSize,
                      columns: 5,
                      rows: 7,
                      keyboard: keyboardInverted
                          ? [
                              "eˣ",
                              "sin⁻¹",
                              "cos⁻¹",
                              "tan⁻¹",
                              "cot⁻¹",
                              "10ˣ",
                              "sinh⁻¹",
                              "cosh⁻¹",
                              "tanh⁻¹",
                              "coth⁻¹",
                              "x²",
                              "",
                              "",
                              "",
                              "",
                              "^",
                              "",
                              "",
                              "",
                              "",
                              "|x|",
                              "",
                              "",
                              "",
                              "",
                              "e",
                              "",
                              "",
                              "",
                              "",
                              useRadians ? "RAD" : "DEG",
                              "",
                              "",
                              "",
                              "",
                            ]
                          : [
                              "ln",
                              "sin",
                              "cos",
                              "tan",
                              "cot",
                              "log",
                              "sinh",
                              "cosh",
                              "tanh",
                              "coth",
                              "√",
                              "",
                              "",
                              "",
                              "",
                              "^",
                              "",
                              "",
                              "",
                              "",
                              "x!",
                              "",
                              "",
                              "",
                              "",
                              "π",
                              "",
                              "",
                              "",
                              "",
                              useRadians ? "RAD" : "DEG",
                              "",
                              "",
                              "",
                              "",
                            ],
                      keyboardToken: keyboardInverted
                          ? [
                              "e^",
                              "asin(",
                              "acos(",
                              "atan(",
                              "acot(",
                              "10^",
                              "asinh(",
                              "acosh(",
                              "atanh(",
                              "acoth(",
                              "^2",
                              "",
                              "",
                              "",
                              "",
                              "^",
                              "",
                              "",
                              "",
                              "",
                              "abs(",
                              "",
                              "",
                              "",
                              "",
                              "e",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                            ]
                          : [
                              "ln(",
                              "sin(",
                              "cos(",
                              "tan(",
                              "cot(",
                              "log(",
                              "sinh(",
                              "cosh(",
                              "tanh(",
                              "coth(",
                              "√(",
                              "",
                              "",
                              "",
                              "",
                              "^",
                              "",
                              "",
                              "",
                              "",
                              "!",
                              "",
                              "",
                              "",
                              "",
                              "π",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                            ],
                      styles: [],
                      defaultBgColor: buttonBackgroundExtended,
                      defaultTextColor: defaultText,
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
                            child: Keyboard(
                              textSize: textSize,
                              rows: 5,
                              columns: 4,
                              keyboard: [
                                "C",
                                "<-",
                                "( )",
                                "×",
                                "7",
                                "8",
                                "9",
                                "÷",
                                "4",
                                "5",
                                "6",
                                "+",
                                "1",
                                "2",
                                "3",
                                "-",
                                "%",
                                "0",
                                ",",
                                "=",
                              ],
                              keyboardToken: [
                                "",
                                "",
                                ")",
                                "*",
                                "7",
                                "8",
                                "9",
                                "/",
                                "4",
                                "5",
                                "6",
                                "+",
                                "1",
                                "2",
                                "3",
                                "-",
                                "%",
                                "0",
                                ",",
                                "",
                              ],
                              styles: [
                                KeyStyle(["="], equalsColor, equalsBackground,
                                    overlayColor: equalsOverlay
                                        ),
                                KeyStyle(["C"], clearAllText, buttonBackgroundBase,
                                    overlayColor:
                                        clearAllOverlay),
                                KeyStyle(["<-", "( )", "+", "-", "%", "×", "÷"],
                                    operatorText, operatorBackground)
                              ],
                              defaultTextColor: defaultText,
                              defaultBgColor: buttonBackgroundBase,
                            ),
                          );
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
                      resultController!.value < 0.8
                          ? resultController!.reverse()
                          : resultController!.forward();
                    }
                    // history not opened at beginning
                    else {
                      resultController!.value > 0.2
                          ? resultController!.forward()
                          : resultController!.reverse();
                    }
                  },
                  onScaleStart: (d) {
                    rTS = resultTextSize;
                  },
                  onScaleUpdate: (d) {
                    resultTextSize = rTS * d.scale;
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                        color: screenAndHistory,
                        boxShadow: resultController!.value == 0
                            ? null
                            : [
                                BoxShadow(offset: Offset(0, 1), blurRadius: 10)
                              ]),
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
                                LimitedBox(maxHeight: 50, child: AdWidget(ad: bannerAd)),
                                TextField(
                                  controller: CalculatorCubit.of(context)
                                      .expressionController,
                                  onTap: CalculatorCubit.of(context)
                                      .expressionController
                                      .adoptCursorPosition,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: resultTextSize,
                                    color: expressionText,
                                  ),
                                  minLines: null,
                                  maxLines: null,
                                  readOnly: true,
                                  showCursor: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: "0"),
                                ),
                                TextField(
                                  controller: CalculatorCubit.of(context)
                                      .resultController,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: resultTextSize,
                                    color: resultText,
                                  ),
                                  minLines: null,
                                  maxLines: null,
                                  readOnly: true,
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                ),
                              ],
                            ),
                          ),
                          resultController!.value == 0 ? Spacer() : Expanded(child: BlocBuilder<CalculatorCubit, CalculatorState>(
                            builder:(context, state) {

                              if (state.history.isEmpty) {
                                return Center(child: Text("Dein Verlauf ist noch leer :)"),);
                              }

                              return ListView.separated(
                                separatorBuilder: (context, index) => Divider(),
                              itemBuilder: (context, i) {
                                print(state.history[i]);
                                return Slidable(
                                  key: ValueKey(i),
                                  child: ListTile(title: Text(state.history[i].replaceAll("#", "")), onTap: () {
                                    CalculatorCubit.of(context).insertFromHistory(i);
                                  },),
                                  endActionPane: ActionPane(motion: ScrollMotion(), children: [
                                    SlidableAction(onPressed: (context) {
                                      CalculatorCubit.of(context).removeFromHistory(i);
                                    }, backgroundColor: removeHistoryItemAction, icon: Icons.delete,)
                                  ]),
                                  );
                              },
                              itemCount: state.history.length,
                              );
                            },
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 400),
                                child: resultController!.value == 0
                                    ? Container(
                                        key: ValueKey(1),
                                      )
                                    : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextButton(onPressed: () {
                                            CalculatorCubit.of(context).clearHistory();
                                          }, child: Text("Verlauf löschen"), style: TextButton.styleFrom(
                                            backgroundColor: clearHistoryBackground,
                                            primary: clearHistoryText,
                                            minimumSize: const Size.fromHeight(50),
                                            textStyle: TextStyle(fontSize: 18)
                                          ),),
                                        ),
                                        Container(
                                            key: ValueKey(2),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: historyHandle),
                                            height: 8,
                                            width: widget.width / 3),
                                      ],
                                    )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
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
  final List<String> keyboardToken;
  final List<KeyStyle> styles;
  final Color defaultBgColor;
  final Color defaultTextColor;

  const Keyboard(
      {Key? key,
      required this.textSize,
      required this.rows,
      required this.columns,
      required this.keyboard,
      required this.keyboardToken,
      required this.styles,
      required this.defaultBgColor,
      required this.defaultTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < rows; i++)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int j = 0; j < columns; j++)
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () {
                            if (keyboard[i * columns + j] == "C") {
                              CalculatorCubit.clearAll(context);
                            } else if (keyboard[i * columns + j] == "<-") {
                              CalculatorCubit.clearOne(context);
                            } else if (keyboard[i * columns + j] == "=") {
                              CalculatorCubit.equals(context);
                            } else if (keyboard[i * columns + j] == "RAD" || keyboard[i * columns + j] == "DEG") {
                              CalculatorCubit.of(context).setUseRadians(!CalculatorCubit.of(context).state.useRadians);
                            } 
                            else {
                              CalculatorCubit.insert(
                                  context, keyboardToken[i * columns + j]);
                            }
                          },
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(styles
                                  .getOverlayColor(keyboard[i * columns + j])),
                              backgroundColor: MaterialStateProperty.all(
                                  styles.getBgColor(keyboard[i * columns + j],
                                      defaultBgColor)),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.zero))),
                              side: MaterialStateProperty.all(
                                  BorderSide(color: spacingColor, width: 0.5))),
                          child: Center(
                              child: AnimatedSwitcher(
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                  child: child, scale: animation);
                            },
                            duration: Duration(milliseconds: 200),
                            child: Builder(
                              key: ValueKey(keyboard[i * columns + j]),
                              builder: (context) {
                                String text = keyboard[i * columns + j];
                                Color color =
                                    styles.getTextColor(text, defaultTextColor);

                                if (text == "<-") {
                                  return Icon(Icons.backspace_outlined, color: color);
                                }  else if (text == "RAD" || text == "DEG") {
                                  return BlocBuilder<CalculatorCubit, CalculatorState>(builder: (context, state) {
                                    return Text(state.useRadians ? "RAD" : "DEG", key: ValueKey(text), style: TextStyle(fontSize: textSize, color: color));
                                  });
                                } else {
                                  return Text(text, style: TextStyle(fontSize: textSize, color: color));
                                }
                              },
                            ),
                          ))))
              ],
            ),
          )
      ],
    );
  }
}
