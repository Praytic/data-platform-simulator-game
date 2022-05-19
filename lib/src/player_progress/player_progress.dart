// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../games_services/score.dart';
import 'persistence/player_progress_persistence.dart';

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  static const maxHighestScoresPerPlayer = 10;

  final PlayerProgressPersistence _store;

  Score _highestScoreReached = Score();

  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  PlayerProgress(PlayerProgressPersistence store) : _store = store;

  /// The highest level that the player has reached so far.
  Score get highestScoreReached => _highestScoreReached;

  /// Fetches the latest data from the backing persistence store.
  Future<void> getLatestFromStore() async {
    final score = await _store.getHighestScoreReached();
    if (score > _highestScoreReached) {
      _highestScoreReached = score;
      notifyListeners();
    } else if (score < _highestScoreReached) {
      await _store.saveHighestScoreReached(_highestScoreReached);
    }
  }

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _highestScoreReached = Score();
    notifyListeners();
    _store.saveHighestScoreReached(_highestScoreReached);
  }

  /// Registers [score] as reached.
  ///
  /// If this is higher than [highestScoreReached], it will update that
  /// value and save it to the injected persistence store.
  void setScoreReached(Score score) {
    if (score > _highestScoreReached) {
      _highestScoreReached = score;
      notifyListeners();

      unawaited(_store.saveHighestScoreReached(score));
    }
  }
}
