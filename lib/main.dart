import 'package:flutter/material.dart';
import 'package:mks_connect/mks_client.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'MKS Connect';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final _channel = MKSClient('ws://dodohub.eu:7000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: _channel.bedTemp,
              builder: (context, snapshot) {
                final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
                return Text("Bed temperature: $temp");
              },
            ),
            StreamBuilder(
              stream: _channel.t0Temp,
              builder: (context, snapshot) {
                final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
                return Text("Extruder 1 temperature: $temp");
              },
            ),
            StreamBuilder(
              stream: _channel.t1Temp,
              builder: (context, snapshot) {
                final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
                return Text("Extruder 2 temperature: $temp");
              },
            ),
            FutureBuilder(
              future: _channel.sdCardFiles,
              builder: ((context, snapshot) {
                var txt = snapshot.hasData
                    ? (snapshot.data as List<String>).join('\n')
                    : 'N/A';

                return Text("SD card files:\n $txt");
              }),
            ),
          ],
        ),
      ),
    );
  }

  // void _sendMessage() {
  //   if (_controller.text.isNotEmpty) {
  //     print("Sending message: ${_controller.text}");
  //     _channel.sink.add(utf8.encode('${_controller.text}\n'));
  //   }
  // }

  @override
  void dispose() {
    // _channel.sink.close();
    _channel.dispose();
    _controller.dispose();
    super.dispose();
  }
}
