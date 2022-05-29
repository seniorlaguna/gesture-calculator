import 'package:calculator/calculator_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ["48A5AEC0AD67D16D5285734B61C36518"]));

  final storage = await HydratedStorage.build(storageDirectory: await getApplicationDocumentsDirectory());
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
      create: (context) => CalculatorCubit(CalculatorState(6, true, []) ,"."),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.light().copyWith(
          textTheme: GoogleFonts.robotoTextTheme(),
        ),
        darkTheme: ThemeData.dark().copyWith(
          textTheme: GoogleFonts.robotoTextTheme(),
        ),
        home: SafeArea(child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                ListTile(title: Text("Kontakt"), onTap: () async {
                  String url = "https://seniorlaguna.github.io/contact.html";
                  if (await canLaunchUrlString(url)) {
                    launchUrlString(url);
                  }
                }),
                ListTile(title: Text("Nutzungsbedingungen"), onTap: () async {
                  String url = "https://seniorlaguna.github.io/calculator/terms_de.html";
                  if (await canLaunchUrlString(url)) {
                    launchUrlString(url);
                  }
                },),
                ListTile(title: Text("Datenschutzrichtlinien"), onTap: () async {
                  String url = "https://seniorlaguna.github.io/calculator/privacy_de.html";
                  if (await canLaunchUrlString(url)) {
                    launchUrlString(url);
                  }
                },),
                
              ],
            ),
          ),
          body: Builder(
          builder: (context) {
            return FutureBuilder(
              future:   () async {
                await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                await Future.delayed(Duration(milliseconds: 500));
              }(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                                return App(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width, MediaQuery.of(context).viewInsets.bottom);
                } 
                return Container();
              }
            );
          }
        ))),
      ),
    );
  }
}