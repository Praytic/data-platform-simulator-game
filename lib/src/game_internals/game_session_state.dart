// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [moneyLowerBoundary], and calls [onWin] when
/// the value of [moneyLowerBoundary] reaches [moneyLowerBoundary].
class GameSessionState extends ChangeNotifier {
  final VoidCallback onWin;

  final int moneyLowerBoundary;

  GameSessionState({required this.onWin, this.moneyLowerBoundary = 0});

  int _progress = 0;

  int get progress => _progress;

  void setProgress(int value) {
    _progress = value;
    notifyListeners();
    if (_progress <= moneyLowerBoundary) {
      onWin();
    }
  }
}