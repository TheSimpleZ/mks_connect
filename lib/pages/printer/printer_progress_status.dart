import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mks_connect/mks_printer.dart';
import 'package:mks_connect/string_extensions.dart';

class PrinterProgressStatus extends ConsumerWidget {
  PrinterProgressStatus({
    Key? key,
    required this.status,
    required this.progress,
  }) : super(key: key);

  final AutoDisposeStreamProvider<PrinterStatus> status;
  final AutoDisposeStreamProvider<int> progress;

  var colorMap = {
    PrinterStatus.idle: Colors.blue,
    PrinterStatus.printing: Colors.green,
    PrinterStatus.paused: Colors.yellow
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusValue = ref.watch(status).valueOrNull ?? PrinterStatus.idle;
    final progressRef = ref.watch(progress);
    final color = colorMap[statusValue];
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: progressRef.whenOrNull(
              data: (data) => CircularProgressIndicator(
                    color: color,
                    strokeWidth: 7,
                    value:
                        statusValue == PrinterStatus.idle ? 0 : data.toDouble(),
                  )),
        ),
        Text(
          statusValue.name.toCapitalized(),
          style: TextStyle(color: color, fontSize: 60),
        )
      ],
    );
  }
}
