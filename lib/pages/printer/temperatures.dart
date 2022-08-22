import 'package:flutter/material.dart';
import 'package:mks_connect/pages/printer/temp_card.dart';

import '../../printer_icons_icons.dart';

class Temperatures extends StatelessWidget {
  const Temperatures({
    super.key,
    required this.bedTemp,
    required this.extruder1Temp,
    required this.extruder2Temp,
  });
  final Stream<int> bedTemp;
  final Stream<int> extruder1Temp;
  final Stream<int> extruder2Temp;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TemperatureCard(
              title: "Bed", temp: bedTemp, iconData: PrinterIcons.hot_surface),
          TemperatureCard(
              title: "Extruder 1",
              temp: extruder1Temp,
              iconData: PrinterIcons.hot_surface),
          TemperatureCard(
              title: "Extruder 2",
              temp: extruder2Temp,
              iconData: PrinterIcons.hot_surface),
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
