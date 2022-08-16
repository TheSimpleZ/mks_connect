import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'printer_page.dart';
import 'settings_page.dart';

void main() => runApp(const MyApp());

class SharedPreferencesBuilder<T> extends StatelessWidget {
  final String pref;
  final AsyncWidgetBuilder<T> builder;

  const SharedPreferencesBuilder({
    super.key,
    required this.pref,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: _future(),
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          return builder(context, snapshot);
        });
  }

  Future<T> _future() async {
    return (await SharedPreferences.getInstance()).get(pref) as T;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'MKS Connect';
    return MaterialApp(
      title: title,
      home: SharedPreferencesBuilder<String>(
        pref: 'host',
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return snapshot.hasData
              ? const PrinterPage(title: title)
              : const SettingsPage(
                  title: title,
                );
        },
      ),
    );
  }
}
