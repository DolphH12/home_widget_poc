import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:home_widget/home_widget.dart';

const MethodChannel platform =
    MethodChannel('com.example.home_widget_poc/channel');

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

// @pragma('vm:entry-point')
// Future<void> interactiveCallback(Uri? uri) async {
//   // We check the host of the uri to determine which action should be triggered.
//   if (uri?.host == 'update') {
//     update('243546');
//   }
// }

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
      body: Center(
        child: Text('Hello World!'),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   update('123456');
      // })),
    ));
  }
}

// void update(String code) {
//   // Add from here
//   HomeWidget.saveWidgetData<String>('text_secret', code);
//   // HomeWidget.updateWidget(
//   //   androidName: androidWidgetName,
//   // );
// }
