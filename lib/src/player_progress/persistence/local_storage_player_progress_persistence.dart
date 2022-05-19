// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

import '../../games_services/score.dart';
import 'player_progress_persistence.dart';

/// An implementation of [PlayerProgressPersistence] that uses
/// `package:shared_preferences`.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<Score> getHighestScoreReached() async {
    final prefs = await instanceFuture;
    return Score(
        value: prefs.getInt('highestScoreReached') ?? 0,
        duration:
            Duration(seconds: prefs.getInt('highestDurationReached') ?? 0));
  }

  @override
  Future<void> saveHighestScoreReached(Score score) async {
    final prefs = await instanceFuture;
    await [
      prefs.setInt('highestScoreReached', score.value),
      prefs.setInt('highestDurationReached', score.duration.inSeconds)
    ];
  }
}
