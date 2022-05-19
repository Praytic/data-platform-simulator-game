// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../games_services/score.dart';
import 'player_progress_persistence.dart';

/// An in-memory implementation of [PlayerProgressPersistence].
/// Useful for testing.
class MemoryOnlyPlayerProgressPersistence implements PlayerProgressPersistence {
  Score score = Score();

  @override
  Future<Score> getHighestScoreReached() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return score;
  }

  @override
  Future<void> saveHighestScoreReached(Score score) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    this.score = score;
  }
}
