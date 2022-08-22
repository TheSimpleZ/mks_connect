import 'package:flutter/material.dart';
import 'package:mks_connect/pages/printer/printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  final String title = "MKS Connect";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host');
    final port = prefs.getString('port');
    if (host != null) {
      _hostController.text = host;
    }
    if (port != null) {
      _portController.text = port;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Host',
                ),
              ),
              TextField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(150, 50)),
                onPressed: () {
                  final nav = Navigator.of(context);
                  () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('host', _hostController.text);
                    prefs.setString('port', _portController.text);
                    nav.pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => PrinterPage(
                            host: _hostController.text,
                            port: _portController.text),
                      ),
                    );
                  }();
                },
                child: const Text('Connect'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
