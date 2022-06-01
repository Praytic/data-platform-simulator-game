// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'entities.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [moneyLowerBoundary], and calls [onWin] when
/// the value of [moneyLowerBoundary] reaches [moneyLowerBoundary].
class GameSessionState extends ChangeNotifier {
  final VoidCallback onWin;

  final int moneyLowerBoundary;
  final int initialMoney;

  GameSessionState({
    required this.onWin,
    this.moneyLowerBoundary = 0,
  this.initialMoney = 10,
  });

  int _progress = 0;
  List<Employee> _employees = [Employee()];

  int get progress => _progress;

  void setProgress(Timer gameTimer) {
    _progress = initialMoney -
        _employees
            .map((e) => e.costPerSecond * gameTimer.tick)
            .reduce((value, element) => value + element);
    notifyListeners();
    if (_progress <= moneyLowerBoundary) {
      gameTimer.cancel();
      onWin();
    }
  }
}