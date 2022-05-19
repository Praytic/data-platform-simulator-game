// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Encapsulates a score and the arithmetic to compute it.
@immutable
class Score {
  final int value;

  final Duration duration;

  Score.valueCalculated(this.duration): this.value = duration.inSeconds.abs() + 1;

  Score({this.value = 0, this.duration = const Duration()});

  String get formattedTime {
    final buf = StringBuffer();
    if (duration.inHours > 0) {
      buf.write('${duration.inHours}');
      buf.write(':');
    }
    final minutes = duration.inMinutes % Duration.minutesPerHour;
    if (minutes > 9) {
      buf.write('$minutes');
    } else {
      buf.write('0');
      buf.write('$minutes');
    }
    buf.write(':');
    buf.write((duration.inSeconds % Duration.secondsPerMinute)
        .toString()
        .padLeft(2, '0'));
    return buf.toString();
  }

  /// Whether this [Score] is lower than [other].
  bool operator <(Score other) => this.value < other.value;

  /// Whether this [Score] is higher than [other].
  bool operator >(Score other) => this.value > other.value;

  /// Whether this [Score] is lower than or equal to [other].
  bool operator <=(Score other) => this.value <= other.value;

  /// Whether this [Score] is higher than or equal to [other].
  bool operator >=(Score other) => this.value >= other.value;

  @override
  String toString() => 'Score<$value,$formattedTime>';
}
