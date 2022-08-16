import 'package:flutter/material.dart';
import 'package:mks_connect/mks_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  final TextEditingController _controller = TextEditingController();
  // late final _channel = MKSClient('ws://${widget.host}:${widget.port}');
  MKSClient? _channel;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host');
    final port = prefs.getString('port');
    setState(() {
      _channel = MKSClient('ws://$host:$port');
    });
  }

  @override
  Widget build(BuildContext context) {
    return _channel != null
        ? ConnectedPrinter(title: widget.title, client: _channel!)
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: const Padding(
                padding: EdgeInsets.all(20.0), child: Text('Loading...')),
          );
  }

  @override
  void dispose() {
    _channel?.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class ConnectedPrinter extends StatefulWidget {
  const ConnectedPrinter({
    super.key,
    required this.title,
    required this.client,
  });
  final String title;
  final MKSClient client;
  @override
  State<ConnectedPrinter> createState() => _ConnectedPrinterState();
}

class _ConnectedPrinterState extends State<ConnectedPrinter> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = [];

  @override
  void initState() {
    _widgetOptions = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: widget.client.bedTemp,
            builder: (context, snapshot) {
              final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
              return Text("Bed temperature: $temp");
            },
          ),
          StreamBuilder(
            stream: widget.client.t0Temp,
            builder: (context, snapshot) {
              final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
              return Text("Extruder 1 temperature: $temp");
            },
          ),
          StreamBuilder(
            stream: widget.client.t1Temp,
            builder: (context, snapshot) {
              final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
              return Text("Extruder 2 temperature: $temp");
            },
          ),
        ],
      ),
      FutureBuilder(
        future: widget.client.sdCardFiles,
        builder: ((context, snapshot) {
          var txt = snapshot.hasData
              ? (snapshot.data as List<String>).join('\n')
              : 'N/A';

          return Text("SD card files:\n $txt");
        }),
      ),
    ];
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.thermostat),
              label: 'Temperatures',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sd_card),
              label: 'SD Card',
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped),
    );
  }
}
