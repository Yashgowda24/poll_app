import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class GMTTimeWidget extends StatefulWidget {
  @override
  _GMTTimeWidgetState createState() => _GMTTimeWidgetState();
}

class _GMTTimeWidgetState extends State<GMTTimeWidget> {
  Timer? _timer;
  String? _formattedTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final tz.Location gmtLocation = tz.getLocation('GMT');
    final tz.TZDateTime nowInGMT = tz.TZDateTime.now(gmtLocation);
    final DateFormat dateFormat = DateFormat('d-M-y hh:mm a');
    final String formattedTime = dateFormat.format(nowInGMT);

    setState(() {
      _formattedTime = formattedTime;
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime!,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }
}
