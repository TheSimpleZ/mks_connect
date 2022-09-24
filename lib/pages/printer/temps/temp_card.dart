import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mks_connect/pages/printer/heating/heating.dart';

import '../../../mks_printer.dart';

class TemperatureCard extends ConsumerWidget {
  const TemperatureCard(this.part);
  final HeatablePart part;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void _onItemTapped() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Heating(part),
        ),
      );
    }

    final current = ref.watch(part.currentTemperature);
    final target = ref.watch(part.targetTemperature);


    return GestureDetector(
      onTap: _onItemTapped,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(part.icon, size: 50),
              const SizedBox(height: 20.0),
              Text(part.name),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  current.when(
                    data: (temp) => Text(temp.toString()),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text(e.toString())),
                  ),
                  const Text("/"),
                  target.when(
                    data: (temp) => Text(temp.toString()),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text(e.toString())),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
