import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'mks_printer.dart';
import 'pages/printer/printer.dart';
import 'pages/sdcard.dart';

class MainDrawer extends HookConsumerWidget {
  const MainDrawer({
    Key? key,
    required this.printer,
  }) : super(key: key);

  final MKSPrinter printer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = useState<Widget?>(null);

    navigateTo(Widget page) {
      if (currentPage.value.runtimeType == page.runtimeType) {
        return null;
      }

      debugPrint(currentPage.value.runtimeType.toString());

      return () {
        currentPage.value = page;
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
            onTap: navigateTo(PrinterPage(printer: printer)),
          ),
          ListTile(
            leading: const Icon(Icons.sd_card),
            title: const Text('SD Card'),
            onTap: () {
              ref.refresh(printer.sdCardFiles.future);
              final nav = navigateTo(SdCardPage(printer: printer));
              if (nav != null) {
                nav();
              }
            },
          ),
        ],
      ),
    );
  }
}
