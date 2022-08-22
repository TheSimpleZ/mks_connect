import 'dart:convert';

import 'package:async/async.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

class Heatable {
  Stream<int> currentTemperature;
  Stream<int> targetTemperature;

  Heatable(
    this.currentTemperature,
    this.targetTemperature,
  );
}

class Bed extends Heatable {
  Bed(
    Stream<int> currentTemperature,
    Stream<int> targetTemperature,
  ) : super(currentTemperature, targetTemperature);
}

class Nozzle extends Heatable {
  Nozzle(
    Stream<int> currentTemperature,
    Stream<int> targetTemperature,
  ) : super(currentTemperature, targetTemperature);
}

class Extruder extends Heatable {
  Extruder(
    Stream<int> currentTemperature,
    Stream<int> targetTemperature,
  ) : super(currentTemperature, targetTemperature);
}

class MKSPrinter {
  final WebSocketChannel _channel;

  late final _parsedStream = _channel.stream
      .asBroadcastStream()
      .cast<List<int>>()
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  Stream<int> _parseTemp(String groupName) => _parsedStream
      .where((line) => temperatureReadingPattern.hasMatch(line))
      .map((line) =>
          temperatureReadingPattern.firstMatch(line)!.namedGroup(groupName)!)
      .map(int.parse);

  late final bed = Bed(_parseTemp("bed"), _parseTemp("bed_target"));
  late final extruder1 = Extruder(_parseTemp("t0"), _parseTemp("t0_target"));
  late final extruder2 = Extruder(_parseTemp("t1"), _parseTemp("t1_target"));
  late final nozzle = Nozzle(_parseTemp("nozzle"), _parseTemp("nozzle_target"));

  MKSPrinter(String uri)
      : _channel = WebSocketChannel.connect(
          Uri.parse(uri),
        ) {
    _parsedStream.listen(print);
    sendCommand(MSKCommands.preheatBed, payload: "S0");
  }

  void dispose() {
    _channel.sink.close();
  }

  sendCommand(String command, {String? payload}) {
    final cmd = payload == null ? command : "$command $payload";
    print("Sending command: $cmd");
    _channel.sink.add(utf8.encode('$cmd\n'));
  }

  Future<List<String>> get sdCardFiles async {
    final events = StreamQueue(_parsedStream);
    sendCommand(MSKCommands.listFiles);

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
