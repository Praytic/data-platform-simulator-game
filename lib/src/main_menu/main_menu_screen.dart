// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:game_template/src/main_menu/top_score_widget.dart';
import 'package:game_template/src/player_progress/player_progress.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/games_services.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {

  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final gamesServicesController = context.watch<GamesServicesController?>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();
    final playerProgress = context.read<PlayerProgress>();

    final playButton = ElevatedButton(
      onPressed: () {
        audioController.playSfx(SfxType.buttonTap);
        GoRouter.of(context).go('/play');
      },
      child: const Text('Play'),
    );
    final achievementsButton;
    final leaderboardButton;
    final topScoreText;
    if (gamesServicesController != null) {
      achievementsButton = _hideUntilReady(
        ready: gamesServicesController.signedIn,
        child: ElevatedButton(
          onPressed: () => gamesServicesController.showAchievements(),
          child: const Text('Achievements'),
        ),
      );
      leaderboardButton = _hideUntilReady(
        ready: gamesServicesController.signedIn,
        child: ElevatedButton(
          onPressed: () => gamesServicesController.showLeaderboard(),
          child: const Text('Leaderboard'),
        ),
      );
      topScoreText = null;
    } else {
      topScoreText = TopScoreWidget();
      achievementsButton = null;
      leaderboardButton = null;
    }
    final settingsButton = ElevatedButton(
      onPressed: () => GoRouter.of(context).go('/settings'),
      child: const Text('Settings'),
    );
    final volumeControlButton = Padding(
      padding: const EdgeInsets.only(top: 32),
      child: ValueListenableBuilder<bool>(
        valueListenable: settingsController.muted,
        builder: (context, muted, child) {
          return IconButton(
            onPressed: () => settingsController.toggleMuted(),
            icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
          );
        },
      ),
    );
    final headerLogo = Center(
      child: Transform.rotate(
        angle: -0.1,
        child: const Text(
          'Flutter Game Template!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Permanent Marker',
            fontSize: 55,
            height: 1,
          ),
        ),
      ),
    );
    final menuOptions = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        playButton,
        _gap,
        if (gamesServicesController != null) ...[
          achievementsButton,
          _gap,
          leaderboardButton,
          _gap,
        ] else ...[
          topScoreText,
          _gap,
        ],
        settingsButton,
        _gap,
        volumeControlButton,
        _gap,
        const Text('Music by Mr Smith'),
        _gap,
      ],
    );

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        mainAreaProminence: 0.45,
        squarishMainArea: headerLogo,
        rectangularMenuArea: menuOptions,
      ),
    );
  }

  /// Prevents the game from showing game-services-related menu items
  /// until we're sure the player is signed in.
  ///
  /// This normally happens immediately after game start, so players will not
  /// see any flash. The exception is folks who decline to use Game Center
  /// or Google Play Game Services, or who haven't yet set it up.
  Widget _hideUntilReady({required Widget child, required Future<bool> ready}) {
    return FutureBuilder<bool>(
      future: ready,
      builder: (context, snapshot) {
        // Use Visibility here so that we have the space for the buttons
        // ready.
        return Visibility(
          visible: snapshot.data ?? false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: child,
        );
      },
    );
  }

  static const _gap = SizedBox(height: 10);
}
