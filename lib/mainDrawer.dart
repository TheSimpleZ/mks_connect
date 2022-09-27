import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'mks_printer.dart';
import 'pages/printer/printer.dart';
import 'pages/sdcard.dart';

class MainDrawer extends HookConsumerWidget {
  const MainDrawer({
    Key? key,
    required this.printer,
    required this.currentPage,
  }) : super(key: key);

  final MKSPrinter printer;
  final Widget currentPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    navigateTo(Widget page, int id) {
      if (currentPage.runtimeType == page.runtimeType) {
        return null;
      }

      return () {
        return Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      };
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
            onTap: navigateTo(PrinterPage(printer: printer), 0),
          ),
          ListTile(
            leading: const Icon(Icons.sd_card),
            title: const Text('SD Card'),
            onTap: () {
              ref.refresh(printer.sdCardFiles.future);
              final nav = navigateTo(SdCardPage(printer: printer), 1);
              if (nav != null) {
                nav();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
