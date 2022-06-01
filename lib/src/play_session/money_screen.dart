// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_template/src/game_internals/entities.dart';
import 'package:logging/logging.dart' hide Level;


class MoneyScreen extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int value;
  final int limit;

  const MoneyScreen(
      {Key? key,
        required this.onChanged,
        required this.value,
        this.limit = 0})
      : super(key: key);

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  static final _log = Logger('MoneyScreen');

  late int _money;
  List<Employee> _employees = [Employee()];

  late Timer _timer;

  int get money => _money;

  @override
  Widget build(BuildContext context) {
    return Text('Money: $_money');
  }

  @override
  void initState() {
    super.initState();

    _money = widget.value;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _money -= _employees
            .map((e) => e.costPerSecond * t.tick)
            .reduce((value, element) => value + element);
        _log.info('Money: $_money');
        widget.onChanged(_money);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
