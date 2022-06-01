// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart' hide Level;

class MoneyScreen extends StatefulWidget {
  final ValueChanged<Timer> onChanged;
  final int value;

  const MoneyScreen(
      {Key? key, required this.onChanged, required this.value})
      : super(key: key);

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  static final _log = Logger('MoneyScreen');

  late Timer _timer;

  @override
  Widget build(BuildContext context) {
    return Text('Money: ${widget.value}');
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      widget.onChanged(t);
      _log.info('Money: ${widget.value}');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
