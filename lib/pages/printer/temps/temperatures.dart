import 'package:flutter/material.dart';

import '../../../mks_printer.dart';
import 'temp_card.dart';

class Temperatures extends StatelessWidget {
  const Temperatures({
    super.key,
    required this.bed,
    required this.nozzle,
  });
  final Bed bed;
  final Nozzle nozzle;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TemperatureCard(bed),
          TemperatureCard(nozzle),
        ],
      ),
    );
  }
}
