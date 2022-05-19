// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
class GameSessionState extends ChangeNotifier {
  final VoidCallback onWin;

  GameSessionState({required this.onWin});

  int _progress = 0;

  int get progress => _progress;

  void setProgress(int value) {
    _progress = value;
    notifyListeners();
  }

  void endGame() {
    onWin();
  }
}
