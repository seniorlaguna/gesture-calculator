import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mexpa_flutter/mexpa_flutter_platform_interface.dart';

class CalculatorState extends Equatable {

  final int decimalPlaces;
  final bool useRadians;
  final List<String> history;

  const CalculatorState(this.decimalPlaces, this.useRadians, this.history);

  @override
  List<Object?> get props => [decimalPlaces, useRadians, history];
}

class CalculatorCubit extends HydratedCubit<CalculatorState> {
  
  final String delimiter;
  final CalculatorTextEditingController expressionController;
  final CalculatorTextEditingController resultController;
  
  CalculatorCubit(CalculatorState state, this.delimiter) : 
  expressionController = CalculatorTextEditingController(expression: [], delimiter: delimiter), 
  resultController = CalculatorTextEditingController(expression: [], delimiter: delimiter),
  super(state) {
    MexpaFlutterPlatform.instance.setDecimalPlaces(state.decimalPlaces);
    MexpaFlutterPlatform.instance.setUseRadians(state.useRadians);
  }
  
  void setDecimalPlaces(int decimalPlaces) {
    if (decimalPlaces < 1) return;
    MexpaFlutterPlatform.instance.setDecimalPlaces(decimalPlaces);
    emit(CalculatorState(decimalPlaces, state.useRadians, state.history));
    _showPreview();
  }

  void setUseRadians(bool useRadians) {
    MexpaFlutterPlatform.instance.setUseRadians(useRadians);
    emit(CalculatorState(state.decimalPlaces, useRadians, state.history));
    _showPreview();
  }

  void clearHistory() {
    emit(CalculatorState(state.decimalPlaces, state.useRadians, []));
  }

  void insertFromHistory(int index) {
    List<String> newExpression = state.history[index].split("#");
    expressionController.setExpression(newExpression);
  }

  void removeFromHistory(int index) {
    List<String> newHistory = List.from(state.history);
    newHistory.removeAt(index);
    emit(CalculatorState(state.decimalPlaces, state.useRadians, newHistory));
  } 

  static CalculatorCubit of(BuildContext context) => BlocProvider.of<CalculatorCubit>(context);

  Future<void> _showPreview() async {
    String expression = expressionController.text.replaceAll(delimiter, "").replaceAll(",", ".");
    String? result = await MexpaFlutterPlatform.instance.eval(expression);
    resultController.clearAll();
    if (result != null) {
      if (result == expression) return;
      resultController.clearAll();
      resultController.insertNumber(result.replaceAll(".", ","));
    }
  }

  static Future<void> insert(BuildContext context, String token) async {
    of(context).expressionController.insert(token);
    of(context)._showPreview();
  }
  
  static void clearOne(BuildContext context) async {
    of(context).expressionController.clearOne();
    of(context)._showPreview();
  }

  static void clearAll(BuildContext context) {
    of(context).expressionController.clearAll();
    of(context).resultController.clearAll();
  }

  static Future<void> equals(BuildContext context) async {
    CalculatorCubit cubit = of(context);
    String expression = cubit.expressionController.text.replaceAll(cubit.delimiter, "").replaceAll(",", ".");
    String? result = await MexpaFlutterPlatform.instance.eval(expression);
    if (result != null) {
      List<String> newHistory = List.from(cubit.state.history);
      newHistory.insert(0, cubit.expressionController.expression.join("#"));
      cubit.emit(CalculatorState(cubit.state.decimalPlaces, cubit.state.useRadians, newHistory));
      cubit.expressionController.clearAll();
      cubit.resultController.clearAll();
      cubit.expressionController.insertNumber(result.replaceAll(".", ","));
    } else {
      cubit.resultController.clearAll();
      cubit.resultController.text = "Error";
    }
  }
  
  @override
  CalculatorState? fromJson(Map<String, dynamic> json) {
    return CalculatorState(json["decimalPlaces"], json["useRadians"], json["history"]);
  }
  
  @override
  Map<String, dynamic>? toJson(CalculatorState state) {
    return {
      "decimalPlaces" : state.decimalPlaces,
      "useRadians" : state.useRadians,
      "history" : state.history
    };
  }
}


class CalculatorTextEditingController extends TextEditingController {
  static const String _cursorSymbol = "|";

  final List<String> expression;
  final String delimiter;

  CalculatorTextEditingController({required this.expression, this.delimiter = " "});

  void _f(String? insert) {
    int baseOffset = selection.baseOffset;

    int i = 0;

    if (baseOffset == -1) {
      i = expression.length - 1;
    } else if (baseOffset == 0) {
      i = -1;
    } else {
      int charCount = 0;
      for (i = 0; i < expression.length; i++) {
        charCount += expression[i].length;
        if (charCount == baseOffset) break;
      }
    }

    expression.insert(i+1, _cursorSymbol);
    

    if (insert == null) {
      if (i >= 0) expression.removeAt(i);
    } else {
      expression.insert(i+1, insert);
    }

    _formatExpression();

    baseOffset = expression.join().indexOf(_cursorSymbol);

    expression.removeWhere((element) => element == _cursorSymbol);

    value = TextEditingValue(text: expression.join(), selection: TextSelection.fromPosition(TextPosition(offset: baseOffset)));
  }

  void insert(String s) {
    _f(s);
  }

  void insertNumber(String s) {
    for (int i = 0; i < s.length; i++) {
      insert(s[i]);
    }
  }

  void setExpression(List<String> newExpression) {
    expression.clear();
    expression.addAll(newExpression);
    _formatExpression();
    value = TextEditingValue(text: expression.join());
  }

  void clearOne() {
    _f(null);
    adoptCursorPosition();
  }

  void clearAll() {
    expression.clear();
    clear();
  }

  void adoptCursorPosition() {
    int pos = selection.baseOffset;

    if (pos <= 0) return;

    int previousLenght = 0;
    int currentLength = 0;
    for (String s in expression) {
      previousLenght = currentLength;
      currentLength += s.length;


      if (pos == currentLength) {
        if (s != delimiter) return;
        pos = pos - delimiter.length;
      }
      if (previousLenght < pos && pos < currentLength) {
        pos = currentLength;
      }
    }

    selection = TextSelection.fromPosition(TextPosition(offset: pos));
  }

  void _formatExpression() {
    int digitsTillNow = 0;
    List<String> result = [];

    for (int i = expression.length - 1; i >= 0; i--) {
      String current = expression[i];

      if (current == delimiter) continue;

      if (current == _cursorSymbol) {}
      else if (_isDigit(current) && !_isAfterDot(i)) {

        if (digitsTillNow == 3) {
          result.insert(0, delimiter);
          digitsTillNow = 1;
        } else {
          digitsTillNow++;
        }
      } else {
        digitsTillNow = 0;
      }

      result.insert(0, current);
    }

    expression.clear();
    expression.addAll(result);
  }

  bool _isDigit(String s) => RegExp(r"[0123456789]").hasMatch(s);

  bool _isAfterDot(int i) {
    for (int j = i; j >= 0; j--) {
      String current = expression[j];
      if (current == ",") return true;
      if (!_isDigit(current) && current != delimiter && current != _cursorSymbol) return false;
    }

    return false;
  }
}
