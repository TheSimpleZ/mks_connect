import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/printer/printer.dart';
import 'pages/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final host = prefs.getString('host');

  final homepage = host != null
      ? PrinterPage(host: host, port: prefs.getString('port') ?? "7000")
      : const SettingsPage();

  runApp(MaterialApp(
    title: 'MKS Connect',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: homepage,
  ));
}
