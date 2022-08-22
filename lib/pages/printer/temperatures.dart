import 'package:flutter/material.dart';
import 'package:mks_connect/mks_printer.dart';
import 'package:mks_connect/pages/printer/temp_card.dart';

import '../../printer_icons_icons.dart';

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
    return SizedBox(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TemperatureCard(
            title: "Bed",
            temp: bed.currentTemperature,
            iconData: PrinterIcons.hot_surface,
          ),
          TemperatureCard(
            title: "Nozzle",
            temp: nozzle.currentTemperature,
            iconData: PrinterIcons.hot_surface,
          ),
        ],
      ),
    );

    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     StreamBuilder(
    //       stream: bedTemp,
    //       builder: (context, snapshot) {
    //         final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
    //         return Text("Bed: $temp");
    //       },
    //     ),
    //     StreamBuilder(
    //       stream: extruder1Temp,
    //       builder: (context, snapshot) {
    //         final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
    //         return Text("Extruder 1: $temp");
    //       },
    //     ),
    //     StreamBuilder(
    //       stream: extruder2Temp,
    //       builder: (context, snapshot) {
    //         final temp = snapshot.hasData ? "${snapshot.data}" : 'N/A';
    //         return Text("Extruder 2: $temp");
    //       },
    //     ),
    //   ],
    // );
  }
}
