import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../../mks_printer.dart';

class Heating extends HookConsumerWidget {
  final HeatablePart part;
  const Heating(this.part, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(part.currentTemperature);
    final target = ref.watch(part.targetTemperature);
    final currentTarget = useState(0);

    tempStream(stream) => StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            final temp = snapshot.hasData ? "${snapshot.data}°C" : 'N/A';
            return Text(temp);
          },
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(part.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.thermostat, size: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text("Current:"),
                    current.when(
                      data: (temp) => Text(temp.toString()),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text(e.toString())),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text("Target:"),
                    target.when(
                      data: (temp) => Text(temp.toString()),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text(e.toString())),
                    ),
                  ],
                ),
              ],
            ),
            NumberPicker(
              value: currentTarget.value,
              minValue: 0,
              maxValue: 100,
              onChanged: (value) => currentTarget.value = value,
            ),
          ],
        ),
      ),
    );
  }
}
