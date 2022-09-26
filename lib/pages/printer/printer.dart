import 'package:flutter/material.dart';
import 'package:mks_connect/mks_printer.dart';

import 'printer_progress_status.dart';
import 'temps/temperatures.dart';

class PrinterPage extends StatefulWidget {
  final String host;
  final String port;
  final MKSPrinter printer;

  PrinterPage({
    super.key,
    required this.host,
    required this.port,
  }) : printer = MKSPrinter('ws://$host:$port');

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrinterProgressStatus(
              status: widget.printer.status, progress: widget.printer.progress),
          const SizedBox(width: 50),
          Temperatures(
            bed: widget.printer.bed,
            nozzle: widget.printer.nozzle,
          ),
        ],
      ),
      FutureBuilder(
        future: widget.printer.sdCardFiles,
        builder: ((context, snapshot) {
          var txt = snapshot.hasData
              ? (snapshot.data as List<String>).join('\n')
              : 'N/A';

          return Text("SD card files:\n $txt");
        }),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("MKS Connect"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        // child: _widgetOptions(_selectedIndex),
        child: IndexedStack(
          index: _selectedIndex,
          children: widgets,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.print),
            label: 'Printer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sd_card),
            label: 'SD Card',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
