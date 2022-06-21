import 'dart:io';
import 'dart:math';

import 'package:calculator/calculator_framework.dart';
import 'package:calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';

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

  bool adLoaded = false;
  BannerAd? bannerAd;

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

    _loadAds();
    
    _askForReview();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    resultController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    heightTween = Tween<double>(
            begin: 0.625 * widget.height + widget.bottomPadding,
            end: (0.625 * widget.height + widget.bottomPadding) * 5 / 7)
        .animate(CurvedAnimation(parent: controller!, curve: curve));

    widthTween = Tween<double>(begin: widget.width, end: widget.width * 0.8)
        .animate(CurvedAnimation(parent: controller!, curve: curve));
    resultHeightTween =
        Tween<double>(begin: 0.375, end: 1).animate(resultController!);
  }

  void _askForReview() async {
    var cubit = CalculatorCubit.of(context);
    if (cubit.state.history.length < 10 || cubit.state.askedForReview) return;
    
    cubit.setAskedForReview();
    if (await InAppReview.instance.isAvailable()) {
      InAppReview.instance.requestReview();
    }
  }

  void _loadAds() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: "ca-app-pub-7519220681088057/7416942476",
        listener: BannerAdListener(
            onAdLoaded: (_) => setState(() {
                  adLoaded = true;
                })),
        request: const AdRequest());
    bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final CalculatorTheme theme =
        Theme.of(context).extension<CalculatorTheme>()!;

    final size = MediaQuery.of(context).size.width / 4;

    return Stack(
      children: [
        // keyboard
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
                  SizedBox(
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
                              "sin⁻¹(",
                              "cos⁻¹(",
                              "tan⁻¹(",
                              "cot⁻¹(",
                              "10^",
                              "sinh⁻¹(",
                              "cosh⁻¹(",
                              "tanh⁻¹(",
                              "coth⁻¹(",
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
                      styles: const [],
                      defaultBgColor: theme.buttonBackgroundExtended,
                      defaultTextColor: theme.defaultText,
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: AnimatedBuilder(
                        animation: controller!,
                        builder: (context, child) {
                          return SizedBox(
                            height: heightTween!.value,
                            width: widthTween!.value,
                            child: Keyboard(
                              textSize: textSize * 1.2,
                              rows: 5,
                              columns: 4,
                              keyboard: [
                                "C",
                                "<-",
                                "( )",
                                "÷",
                                "7",
                                "8",
                                "9",
                                "×",
                                "4",
                                "5",
                                "6",
                                "-",
                                "1",
                                "2",
                                "3",
                                "+",
                                "%",
                                "0",
                                Platform.localeName.startsWith("de") ? "," : ".",
                                "=",
                              ],
                              keyboardToken: [
                                "",
                                "",
                                "()",
                                "/",
                                "7",
                                "8",
                                "9",
                                "*",
                                "4",
                                "5",
                                "6",
                                "-",
                                "1",
                                "2",
                                "3",
                                "+",
                                "%",
                                "0",
                                Platform.localeName.startsWith("de") ? "," : ".",
                                "",
                              ],
                              styles: [
                                KeyStyle(["="], theme.equalsColor,
                                    theme.equalsBackground,
                                    overlayColor: theme.equalsOverlay),
                                KeyStyle(["C"], theme.clearAllText,
                                    theme.buttonBackgroundBase,
                                    overlayColor: theme.clearAllOverlay),
                                KeyStyle(
                                    ["<-", "( )", "+", "-", "%", "×", "÷"],
                                    theme.operatorText,
                                    theme.operatorBackground)
                              ],
                              defaultTextColor: theme.defaultText,
                              defaultBgColor: theme.buttonBackgroundBase,
                            ),
                          );
                        },
                      ))
                ],
              ),
            ),
          ),
        ),
        
        // display and history
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
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                        color: theme.screenAndHistory,
                        boxShadow: resultController!.value == 0
                            ? null
                            : [
                                const BoxShadow(offset: Offset(0, 1), blurRadius: 10)
                              ]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // display
                          SizedBox(
                            height: widget.height * 0.375 - 16,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (adLoaded) LimitedBox(
                                      maxHeight: 50,
                                      child: AdWidget(ad: bannerAd!)),
                                  TextField(
                                    controller: CalculatorCubit.of(context)
                                        .expressionController,
                                    onTap: CalculatorCubit.of(context)
                                        .expressionController
                                        .adoptCursorPosition,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: resultTextSize,
                                      color: theme.expressionText,
                                    ),
                                    minLines: null,
                                    maxLines: null,
                                    readOnly: true,
                                    showCursor: true,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "0"),
                                  ),
                                  TextField(
                                    controller: CalculatorCubit.of(context)
                                        .resultController,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: resultTextSize,
                                      color: theme.resultText,
                                    ),
                                    minLines: null,
                                    maxLines: null,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // history
                          if (resultHeightTween!.value > 0.5) Expanded(child:
                                  BlocBuilder<CalculatorCubit, CalculatorState>(
                                  builder: (context, state) {
                                    if (state.history.isEmpty) {
                                      return Center(
                                          child: FadeTransition(
                                            opacity: resultController!,
                                            child: Text(
                                                                                  FlutterI18n.translate(
                                              context, "history.still_empty"),
                                                                                  style: TextStyle(
                                            color: theme.historyItem,
                                                                                  ),
                                                                                ),
                                          ));
                                    }

                                    return ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          const Divider(),
                                      itemBuilder: (context, i) {
                                        return Slidable(
                                          key: ValueKey(i),
                                          endActionPane: ActionPane(
                                              motion: const ScrollMotion(),
                                              children: [
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    CalculatorCubit.of(context)
                                                        .removeFromHistory(i);
                                                  },
                                                  backgroundColor: theme
                                                      .removeHistoryItemAction,
                                                  icon: Icons.delete,
                                                )
                                              ]),
                                          child: ListTile(
                                            trailing: Text(
                                                state.history[i]
                                                    .replaceAll("#", ""),
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    color: theme.historyItem)),
                                            onTap: () {
                                              CalculatorCubit.of(context)
                                                  .insertFromHistory(i);
                                            },
                                          ),
                                        );
                                      },
                                      itemCount: state.history.length,
                                    );
                                  },
                                )),
                          
                          // clear history button
                          if (resultHeightTween!.value > 0.5)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: Column(
                                          children: [
                                            if (resultHeightTween!.value > 0.5)
                                              FadeTransition(
                                                opacity: resultController!,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      CalculatorCubit.of(
                                                              context)
                                                          .clearHistory();
                                                    },
                                                    style: TextButton.styleFrom(
                                                        backgroundColor: theme
                                                            .clearHistoryBackground,
                                                        primary: theme
                                                            .clearHistoryText,
                                                        minimumSize: const Size
                                                            .fromHeight(50),
                                                        textStyle: const TextStyle(
                                                            fontSize: 18)),
                                                    child: Text(
                                                        FlutterI18n.translate(
                                                            context,
                                                            "history.clear")),
                                                  ),
                                                ),
                                              ),
                                            Container(
                                                key: const ValueKey(2),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: theme.historyHandle),
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
    final CalculatorTheme theme =
        Theme.of(context).extension<CalculatorTheme>()!;

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
                            } else if (keyboard[i * columns + j] == "RAD" ||
                                keyboard[i * columns + j] == "DEG") {
                              CalculatorCubit.of(context).setUseRadians(
                                  !CalculatorCubit.of(context)
                                      .state
                                      .useRadians);
                            } else {
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
                                  const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.zero))),
                              side: MaterialStateProperty.all(
                                  BorderSide(color: theme.spacingColor, width: 0.5))),
                          child: Center(
                              child: AnimatedSwitcher(
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                  scale: animation,
                                  child: child);
                            },
                            duration: const Duration(milliseconds: 200),
                            child: Builder(
                              key: ValueKey(keyboard[i * columns + j]),
                              builder: (context) {
                                String text = keyboard[i * columns + j];
                                Color color =
                                    styles.getTextColor(text, defaultTextColor);

                                if (text == "<-") {
                                  return Icon(Icons.backspace_outlined,
                                      color: color);
                                } else if (text == "RAD" || text == "DEG") {
                                  return BlocBuilder<CalculatorCubit,
                                          CalculatorState>(
                                      builder: (context, state) {
                                    return Text(
                                        state.useRadians ? "RAD" : "DEG",
                                        key: ValueKey(text),
                                        style: TextStyle(
                                            fontSize: textSize, color: color));
                                  });
                                } else {
                                  return Text(text,
                                      style: TextStyle(
                                          fontSize: textSize, color: color));
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
