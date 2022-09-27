import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'printer_icons_icons.dart';

final temperatureReadingPattern = RegExp(
    r"T:(?<nozzle>\d+) /(?<nozzle_target>\d+) B:(?<bed>\d+) /(?<bed_target>\d+) T0:(?<t0>\d+) /(?<t0_target>\d+) T1:(?<t1>\d+) /(?<t1_target>\d+) @:\d+ B@:\d+");

abstract class MSKCommands {
  static const String listFiles = "M20";
  static const String pausePrint = "M25";
  static const String stopPrint = "M26";
  static const String getProgress = "M27";
  static const String preheatBed = "M140";
  static const String getStatus = "M997";
}

abstract class HeatablePart {
  AutoDisposeStreamProvider<int> currentTemperature;
  AutoDisposeStreamProvider<int> targetTemperature;
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
    AutoDisposeStreamProvider<int> currentTemperature,
    AutoDisposeStreamProvider<int> targetTemperature,
  ) : super("Bed", PrinterIcons.hot_surface, currentTemperature,
            targetTemperature);

  @override
  void preHeat(int temp) {
    // TODO: implement preHeat
  }
}

class Nozzle extends HeatablePart {
  Nozzle(
    AutoDisposeStreamProvider<int> currentTemperature,
    AutoDisposeStreamProvider<int> targetTemperature,
  ) : super("Nozzle", Icons.pin_drop_outlined, currentTemperature,
            targetTemperature);

  @override
  void preHeat(int temp) {
    // TODO: implement preHeat
  }
}

class Extruder {
  AutoDisposeStreamProvider<int> currentTemperature;
  AutoDisposeStreamProvider<int> targetTemperature;
  String name;
  IconData icon = Icons.colorize;

  Extruder(
    this.name,
    this.currentTemperature,
    this.targetTemperature,
  );
}

enum PrinterStatus { idle, printing, paused }

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
        ) {
    stream.listen(debugPrint);
  }

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

  AutoDisposeStreamProvider<int> _parseTemp(String groupName) =>
      StreamProvider.autoDispose<int>((ref) => _client.stream
          .where((line) => temperatureReadingPattern.hasMatch(line))
          .map((line) => temperatureReadingPattern
              .firstMatch(line)!
              .namedGroup(groupName)!)
          .map(int.parse));

  Stream<String> _parseCommandResponse(String cmd) => _client.stream
      .where((line) => line.startsWith(cmd))
      .map((line) => line.split(" ")[1].toLowerCase());

  late final bed = Bed(_parseTemp("bed"), _parseTemp("bed_target"));
  late final extruder1 =
      Extruder("Extruder 1", _parseTemp("t0"), _parseTemp("t0_target"));
  late final extruder2 =
      Extruder("Extruder 2", _parseTemp("t1"), _parseTemp("t1_target"));
  late final nozzle = Nozzle(_parseTemp("nozzle"), _parseTemp("nozzle_target"));
  late final status = StreamProvider.autoDispose<PrinterStatus>((ref) =>
      _parseCommandResponse(MSKCommands.getStatus)
          .map(PrinterStatus.values.byName));

  late final progress = StreamProvider.autoDispose<int>(
      (ref) => _parseCommandResponse(MSKCommands.getStatus).map(int.parse));

  MKSPrinter(String uri) : _client = MKSClient(uri) {
    Timer.periodic(const Duration(seconds: 10), _pollForValues);
  }

  void _pollForValues(Timer t) {
    _client.sendCommand(MSKCommands.getStatus);
    _client.sendCommand(MSKCommands.getProgress);
  }

  void dispose() {
    _client.dispose();
  }

  void stop() {
    _client.sendCommand(MSKCommands.stopPrint);
  }

  void pause() {
    _client.sendCommand(MSKCommands.pausePrint);
  }

  late final sdCardFiles = FutureProvider.autoDispose((ref) async {
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
  });
}
