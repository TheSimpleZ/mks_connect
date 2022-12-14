import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/main.dart';
import 'pages/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final host = prefs.getString('host');

  final homepage = host != null
      ? MainPage(host: host, port: prefs.getString('port') ?? "7000")
      : const SettingsPage();

  runApp(ProviderScope(
    child: MaterialApp(
      title: 'MKS Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: homepage,
    ),
  ));
}
