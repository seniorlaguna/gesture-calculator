import 'package:calculator/calculator_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
      testDeviceIds: ["48A5AEC0AD67D16D5285734B61C36518"]));

  final storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());
  HydratedBlocOverrides.runZoned(
    () => runApp(const MyApp()),
    storage: storage,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalculatorCubit>(
      create: (context) => CalculatorCubit(const CalculatorState(6, true, []), "."),
      child: MaterialApp(
        title: "Calculator",
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(decodeStrategies: [YamlDecodeStrategy()]),
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: const [
          Locale("de"),
          Locale("en")
        ],
        theme: ThemeData.light()
            .copyWith(textTheme: GoogleFonts.robotoTextTheme(), extensions: [
          CalculatorTheme(
              const Color(0xFF4047F0),
              Colors.white,
              Colors.white.withOpacity(0.3),
              const Color(0xFFDE5050),
              Colors.redAccent.withOpacity(0.3),
              const Color(0xFFC4C4C4),
              Colors.black54,
              const Color(0xffF6F6F6),
              Colors.white,
              const Color(0xFF4C79EB),
              Colors.white,
              Colors.white,
              Colors.red,
              Colors.black,
              Colors.grey,
              Colors.white,
              const Color(0xFF4047F0),
              Colors.grey,
              Colors.black,
              Colors.black)
        ]),
        darkTheme: ThemeData.dark()
            .copyWith(textTheme: GoogleFonts.robotoTextTheme(), extensions: [
          CalculatorTheme(
              const Color(0xFF4047F0),
              Colors.white,
              Colors.white.withOpacity(0.3),
              const Color(0xFFDE5050),
              Colors.redAccent.withOpacity(0.3),
              Colors.white10,
              Colors.white,
              Colors.black12,
              const Color.fromARGB(255, 55, 55, 55),
              const Color(0xFF4C79EB),
              const Color.fromARGB(255, 55, 55, 55),
              const Color.fromARGB(255, 55, 55, 55),
              Colors.red,
              Colors.white,
              Colors.grey,
              Colors.white,
              const Color(0xFF4047F0),
              Colors.grey,
              Colors.white,
              Colors.white)
        ]),
        home: SafeArea(
            child: Scaffold(
                drawer: Drawer(
                  child: Builder(
            
                    builder: (context) {
                      final CalculatorTheme theme = Theme.of(context).extension<CalculatorTheme>()!;


                      return ListView(
                        children: [
                          ListTile(
                              leading: Icon(Icons.person),
                              title: Text(FlutterI18n.translate(context, "contact.title"), style: TextStyle(color: theme.drawerText),),
                              onTap: () async {
                                String url =
                                    FlutterI18n.translate(context, "contact.url");
                                if (await canLaunchUrlString(url)) {
                                  launchUrlString(url);
                                }
                              }),
                          ListTile(
                            leading: Icon(Icons.casino),
                            title: Text(FlutterI18n.translate(context, "terms.title"), style: TextStyle(color: theme.drawerText)),
                            onTap: () async {
                              String url =
                                  FlutterI18n.translate(context, "terms.url");
                              if (await canLaunchUrlString(url)) {
                                launchUrlString(url);
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.lock),
                            title: Text(FlutterI18n.translate(context, "privacy.title"), style: TextStyle(color: theme.drawerText)),
                            onTap: () async {
                              String url =
                                  FlutterI18n.translate(context, "privacy.url");
                              if (await canLaunchUrlString(url)) {
                                launchUrlString(url);
                              }
                            },
                          ),
                        ],
                      );
                    }
                  ),
                ),
                body: Builder(builder: (context) {
                  return FutureBuilder(future: () async {
                    await SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky);
                    await Future.delayed(Duration(milliseconds: 500));
                  }(), builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return App(
                          MediaQuery.of(context).size.height,
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).viewInsets.bottom);
                    }
                    return Container();
                  });
                }))),
      ),
    );
  }
}

class CalculatorTheme extends ThemeExtension<CalculatorTheme> {
  final Color equalsBackground;
  final Color equalsColor;
  final Color equalsOverlay;
  final Color clearAllText;
  final Color clearAllOverlay;
  final Color spacingColor;
  final Color defaultText;
  final Color buttonBackgroundExtended;
  final Color buttonBackgroundBase;
  final Color operatorText;
  final Color operatorBackground;
  final Color screenAndHistory;
  final Color removeHistoryItemAction;
  final Color expressionText;
  final Color resultText;
  final Color clearHistoryText;
  final Color clearHistoryBackground;
  final Color historyHandle;
  final Color historyItem;
  final Color drawerText;

  CalculatorTheme(
      this.equalsBackground,
      this.equalsColor,
      this.equalsOverlay,
      this.clearAllText,
      this.clearAllOverlay,
      this.spacingColor,
      this.defaultText,
      this.buttonBackgroundExtended,
      this.buttonBackgroundBase,
      this.operatorText,
      this.operatorBackground,
      this.screenAndHistory,
      this.removeHistoryItemAction,
      this.expressionText,
      this.resultText,
      this.clearHistoryText,
      this.clearHistoryBackground,
      this.historyHandle,
      this.historyItem,
      this.drawerText);

  @override
  ThemeExtension<CalculatorTheme> copyWith(
      {Color? equalsBackground,
      Color? equalsColor,
      Color? equalsOverlay,
      Color? clearAllText,
      Color? clearAllOverlay,
      Color? spacingColor,
      Color? defaultText,
      Color? buttonBackgroundExtended,
      Color? buttonBackgroundBase,
      Color? operatorText,
      Color? operatorBackground,
      Color? screenAndHistory,
      Color? removeHistoryItemAction,
      Color? expressionText,
      Color? resultText,
      Color? clearHistoryText,
      Color? clearHistoryBackground,
      Color? historyHandle,
      Color? historyItem,
      Color? drawerText}) {
    return CalculatorTheme(
        equalsBackground ?? this.equalsBackground,
        equalsColor ?? this.equalsColor,
        equalsOverlay ?? this.equalsOverlay,
        clearAllText ?? this.clearAllOverlay,
        clearAllOverlay ?? this.clearAllOverlay,
        spacingColor ?? this.spacingColor,
        defaultText ?? this.defaultText,
        buttonBackgroundExtended ?? this.buttonBackgroundExtended,
        buttonBackgroundBase ?? this.buttonBackgroundBase,
        operatorText ?? this.operatorText,
        operatorBackground ?? this.operatorBackground,
        screenAndHistory ?? this.screenAndHistory,
        removeHistoryItemAction ?? this.removeHistoryItemAction,
        expressionText ?? this.expressionText,
        resultText ?? this.resultText,
        clearHistoryText ?? this.clearHistoryText,
        clearHistoryBackground ?? this.clearHistoryBackground,
        historyHandle ?? this.historyHandle,
        historyItem ?? this.historyItem,
        drawerText ?? this.drawerText);
  }

  @override
  ThemeExtension<CalculatorTheme> lerp(
      ThemeExtension<CalculatorTheme>? other, double t) {
    return this;
  }
}
