import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'printer_icons_icons.dart';

final temperatureReadingPattern = RegExp(
    r"T:(?<nozzle>\d+) /(?<nozzle_target>\d+) B:(?<bed>\d+) /(?<bed_target>\d+) T0:(?<t0>\d+) /(?<t0_target>\d+) T1:(?<t1>\d+) /(?<t1_target>\d+) @:\d+ B@:\d+");

abstract class MSKCommands {
  static const String listFiles = "M20";
  static const String preheatBed = "M140";
}

abstract class MSKStates {
  static String idle = "IDLE";
  static String printing = "PRINTING";
  static String pause = "PAUSE";
}

abstract class HeatablePart {
  StreamProvider<int> currentTemperature;
  StreamProvider<int> targetTemperature;
  String name;
  IconData icon;

  HeatablePart(
    this.name,
    this.icon,
    this.currentTemperature,
    this.targetTemperature,
  );

  void preHeat(int temp);
}

class Bed extends HeatablePart {
  Bed(
    StreamProvider<int> currentTemperature,
    StreamProvider<int> targetTemperature,
  ) : super("Bed", PrinterIcons.hot_surface, currentTemperature,
            targetTemperature);

  @override
  void preHeat(int temp) {
    // TODO: implement preHeat
  }
}

class Nozzle extends HeatablePart {
  Nozzle(
    StreamProvider<int> currentTemperature,
    StreamProvider<int> targetTemperature,
  ) : super("Nozzle", Icons.pin_drop_outlined, currentTemperature,
            targetTemperature);

  @override
  void preHeat(int temp) {
    // TODO: implement preHeat
  }
}

class Extruder {
  StreamProvider<int> currentTemperature;
  StreamProvider<int> targetTemperature;
  String name;
  IconData icon = Icons.colorize;

  Extruder(
    this.name,
    this.currentTemperature,
    this.targetTemperature,
  );
}

class MKSClient {
  final WebSocketChannel _channel;

  late final stream = _channel.stream
      .asBroadcastStream()
      .cast<List<int>>()
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  MKSClient(String uri)
      : _channel = WebSocketChannel.connect(
          Uri.parse(uri),
        );

  void dispose() {
    _channel.sink.close();
  }

  sendCommand(String command, {String? payload}) {
    final cmd = payload == null ? command : "$command $payload";
    debugPrint("Sending command: $cmd");
    _channel.sink.add(utf8.encode('$cmd\n'));
  }
}

class MKSPrinter {
  final MKSClient _client;

  StreamProvider<int> _parseTemp(String groupName) =>
      StreamProvider<int>((ref) => _client.stream
          .where((line) => temperatureReadingPattern.hasMatch(line))
          .map((line) => temperatureReadingPattern
              .firstMatch(line)!
              .namedGroup(groupName)!)
          .map(int.parse));

  late final bed = Bed(_parseTemp("bed"), _parseTemp("bed_target"));
  late final extruder1 =
      Extruder("Extruder 1", _parseTemp("t0"), _parseTemp("t0_target"));
  late final extruder2 =
      Extruder("Extruder 2", _parseTemp("t1"), _parseTemp("t1_target"));
  late final nozzle = Nozzle(_parseTemp("nozzle"), _parseTemp("nozzle_target"));

  MKSPrinter(String uri) : _client = MKSClient(uri);

  void dispose() {
    _client.dispose();
  }

  Future<List<String>> get sdCardFiles async {
    final events = StreamQueue(_client.stream);
    _client.sendCommand(MSKCommands.listFiles);

    while (true) {
      var nextLine = await events.next;
      if (nextLine.startsWith('Begin file list')) {
        await events.next; // Discard system volume info
        break;
      }
    }

    final files = <String>[];
    while (true) {
      final line = await events.next;
      if (line.startsWith('End file list')) {
        break;
      }
      files.add(line);
    }
    events.cancel();
    return files;
  }
}
