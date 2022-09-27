import 'package:flutter/material.dart';
import 'package:mks_connect/mks_printer.dart';

import '../../mainDrawer.dart';
import 'printer_progress_status.dart';
import 'temps/temperatures.dart';

class PrinterPage extends StatelessWidget {
  const PrinterPage({
    Key? key,
    required this.printer,
  }) : super(key: key);

  final MKSPrinter printer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Printer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        // child: _widgetOptions(_selectedIndex),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrinterProgressStatus(
                    status: printer.status, progress: printer.progress),
                const SizedBox(width: 50),
                Temperatures(
                  bed: printer.bed,
                  nozzle: printer.nozzle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => printer.pause(),
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => printer.stop(),
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: MainDrawer(printer: printer, currentPage: this),
    );
  }
}
