import 'dart:convert';

import 'package:async/async.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final temperatureReadingPattern = RegExp(
    r"T:\d+ /0 B:(?<bed>\d+) /0 T0:(?<t0>\d+) /0 T1:(?<t1>\d+) /0 @:\d+ B@:\d+");

abstract class MSKCommands {
  static const String listFiles = "M20";
}

abstract class MSKStates {
  static String idle = "IDLE";
  static String printing = "PRINTING";
  static String pause = "PAUSE";
}

class MKSClient {
  final WebSocketChannel _channel;

  late final _parsedStream = _channel.stream
      .asBroadcastStream()
      .cast<List<int>>()
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  late final _temperatureReadings =
      _parsedStream.where((line) => temperatureReadingPattern.hasMatch(line));

  Stream<int> _parseTemp(String groupName) =>
      _temperatureReadings.map((line) => int.parse(
          temperatureReadingPattern.firstMatch(line)!.namedGroup(groupName)!));

  late final bedTemp = _parseTemp("bed");
  late final t0Temp = _parseTemp("t0");
  late final t1Temp = _parseTemp("t1");

  MKSClient(String uri)
      : _channel = WebSocketChannel.connect(
          Uri.parse(uri),
        ) {
    _parsedStream.listen(print);
  }

  void dispose() {
    _channel.sink.close();
  }

  sendCommand(String command) {
    print("Sending command: $command");
    _channel.sink.add(utf8.encode('$command\n'));
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
