import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mks_connect/mainDrawer.dart';
import 'package:mks_connect/mks_printer.dart';

class SdCardPage extends HookConsumerWidget {
  final MKSPrinter printer;

  const SdCardPage({super.key, required this.printer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(printer.sdCardFiles);
    var selectedFile = useState<int?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text("MKS Connect"),
      ),
      body: files.when(
          data: (data) => ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => Card(
                  color: selectedFile.value == index
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  child: ListTile(
                    onTap: () => selectedFile.value = index,
                    title: Text(
                      data[index],
                      style: TextStyle(
                          color: selectedFile.value == index
                              ? Theme.of(context).colorScheme.inversePrimary
                              : null),
                    ),
                    trailing: const Icon(Icons.check),
                  ),
                ),
              ),
          error: (error, stackTrace) =>
              const Text("Error occured while getting files from printer"),
          loading: () => const CircularProgressIndicator()),
      drawer: MainDrawer(printer: printer),
    );
  }
}
