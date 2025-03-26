//import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:home_widget/home_widget.dart';

const MethodChannel platform =
    MethodChannel('com.example.home_widget_poc/channel');
//const MethodChannel _channel = MethodChannel('home_widget_channel');

Future<void> main() async {
  runApp(const MainApp());
  platform.setMethodCallHandler((call) async {
    if (call.method == "fetchSecretText") {
      Map<String, dynamic> secretText =
          await fetchSecretText(); // 🔥 Aquí llamas al servicio
      return secretText;
    }
    return null;
  });
  platform.setMethodCallHandler((call) async {
    if (call.method == "fetchMessage") {
      Map<String, dynamic> secretText =
          await fetchSecretText(); // 🔥 Aquí llamas al servicio
      return secretText['code'];
    }
    return null;
  });
}

Future<Map<String, dynamic>> fetchSecretText() async {
  await Future.delayed(Duration(seconds: 1)); // Simula un delay de API
  final random = Random();
  int codeAleatorio = 100000 + random.nextInt(900000);
  int timeAleatorio = random.nextInt(60);
  return {
    "code": codeAleatorio.toString(),
    "time": timeAleatorio,
  };
}

const String androidWidgetName = 'NewAppWidget';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // update('******');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Hello World!'),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   update('123456');
      // })),
    ));
  }

  // static Future<void> updateWidget() async {
  //   if (Platform.isIOS) {
  //     try {
  //       final Map<String, dynamic> mapCode = await fetchSecretText();
  //       var sol = await _channel
  //           .invokeMethod('updateWidget', {'message': mapCode['code']});
  //       print(sol);
  //     } on PlatformException catch (e) {
  //       print("Error al actualizar el widget: ${e.message}");
  //     }
  //   }
  // }
}

// void update(String code) {
//   // Add from here
//   HomeWidget.saveWidgetData<String>('text_secret', code);
//   // HomeWidget.updateWidget(
//   //   androidName: androidWidgetName,
//   // );
// }
