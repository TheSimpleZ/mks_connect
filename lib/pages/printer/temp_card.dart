import 'package:flutter/material.dart';

class TemperatureCard extends StatelessWidget {
  const TemperatureCard(
      {super.key,
      required this.title,
      required this.temp,
      required this.iconData});
  final String title;
  final Stream<int> temp;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 50),
            const SizedBox(height: 20.0),
            Text(title),
            const SizedBox(height: 20.0),
            StreamBuilder(
              stream: temp,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}°C' : 'N/A');
              },
            ),
          ],
        ),
      ),
    );
  }
}
