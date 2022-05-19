import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:game_template/src/player_progress/player_progress.dart';
import 'package:provider/provider.dart';

import '../games_services/score.dart';

class TopScoreWidget extends StatefulWidget {

  const TopScoreWidget({Key? key}) : super(key: key);

  @override
  _TopScoreWidgetState createState() => _TopScoreWidgetState();
}

class _TopScoreWidgetState extends State<TopScoreWidget> {

  @override
  Widget build(BuildContext context) {
    final playerProgress = context.watch<PlayerProgress>();
    return Text(
      'Score: ${playerProgress.highestScoreReached.value}\n'
          'Time: ${playerProgress.highestScoreReached.formattedTime}',
      style: const TextStyle(
          fontFamily: 'Permanent Marker', fontSize: 20),
    );
  }
}