// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/game_session_state.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import 'money_screen.dart';

class PlaySessionScreen extends StatefulWidget {
  const PlaySessionScreen({Key? key}) : super(key: key);

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  late Timer _timer;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final victoryStateProvider = ChangeNotifierProvider(
      create: (context) => GameSessionState(onWin: _playerWon),
    );
    final celebrationScreen = SizedBox.expand(
      child: Visibility(
        visible: _duringCelebration,
        child: IgnorePointer(
          child: Confetti(
            isStopped: !_duringCelebration,
          ),
        ),
      ),
    );
    final settingsButton = Align(
      alignment: Alignment.centerRight,
      child: InkResponse(
        onTap: () => GoRouter.of(context).push('/settings'),
        child: Image.asset(
          'assets/images/settings.png',
          semanticLabel: 'Settings',
        ),
      ),
    );
    final core = Consumer<GameSessionState>(
      builder: (context, levelState, child) => MoneyScreen(
        value: 10,
        onChanged: (value) => levelState.setProgress(value),
      ),
    );
    final endGameButton = Consumer<GameSessionState>(
      builder: (context, state, child) => Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => {
              state.onWin(),
            },
            child: const Text('Submit Score'),
          ),
        ),
      ),
    );
    final backButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => GoRouter.of(context).pop(),
          child: const Text('Back'),
        ),
      ),
    );
    final gameScreen = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          settingsButton,
          const Spacer(),
          core,
          Text('Press the button when you want to submit the score'),
          endGameButton,
          backButton,
        ],
      ),
    );
    final gameSessionProvider = IgnorePointer(
      ignoring: _duringCelebration,
      child: Scaffold(
        backgroundColor: palette.backgroundPlaySession,
        body: Stack(
          children: [
            gameScreen,
            celebrationScreen,
          ],
        ),
      ),
    );

    return MultiProvider(
        providers: [victoryStateProvider], child: gameSessionProvider);
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }

  Future<void> _playerWon() async {
    _log.info('Player ended the game');

    final score = Score.valueCalculated(
      DateTime.now().difference(_startOfPlay),
    );
    _log.info('Player score reached: ${score.value}');

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setScoreReached(score);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      // if (widget.level.awardsAchievement) {
      //   await gamesServicesController.awardAchievement(null, null
      //     android: widget.level.achievementIdAndroid!,
      //     iOS: widget.level.achievementIdIOS!,
      //   );
      // }

      // Send score to leaderboard.
      await gamesServicesController.submitLeaderboardScore(score);
    }

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
