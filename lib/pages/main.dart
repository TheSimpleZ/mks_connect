import 'package:flutter/material.dart';

import '../mks_printer.dart';
import 'printer/printer.dart';

class MainPage extends StatelessWidget {
  final String host;
  final String port;
  final MKSPrinter printer;

  MainPage({
    super.key,
    required this.host,
    required this.port,
  }) : printer = MKSPrinter('ws://$host:$port');

  @override
  Widget build(BuildContext context) {
    return PrinterPage(printer: printer);
  }
}
