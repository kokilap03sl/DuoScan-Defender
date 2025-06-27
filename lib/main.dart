import 'package:flutter/material.dart';
import 'themes/theme_notifier.dart';
import 'home_page_1.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'app_state.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _sendAppDataToBackend();
  }

  Future<void> _sendAppDataToBackend() async {
    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.1.3:3000/app-data'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'app': 'DuoScan Defender', 'version': '1.0.0'}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        log('Data sent successfully!');
      } else {
        log('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      log('Error sending data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, themeNotifier, child) {
      return MaterialApp(
        title: 'DuoScan Defender',
        theme: themeNotifier.currentTheme,
        home: const HomePage1(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
