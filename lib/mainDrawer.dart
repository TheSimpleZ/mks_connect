import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'mks_printer.dart';
import 'pages/printer/printer.dart';
import 'pages/printer/sdcard.dart';

class MainDrawer extends HookConsumerWidget {
  const MainDrawer({
    Key? key,
    required this.printer,
  }) : super(key: key);

  final MKSPrinter printer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    navigateTo(Widget page) {
      return () => Navigator.of(context)
        ..pop()
        ..push(
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
    }

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Printer'),
            onTap: navigateTo(PrinterPage(printer: printer)),
          ),
          ListTile(
            leading: const Icon(Icons.sd_card),
            title: const Text('SD Card'),
            onTap: () {
              ref.refresh(printer.sdCardFiles.future);
              navigateTo(SdCardPage(printer: printer))();
            },
          ),
        ],
      ),
    );
  }
}
