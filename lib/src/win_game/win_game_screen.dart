// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  final Score score;

  const WinGameScreen({
    Key? key,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();

    const gap = SizedBox(height: 10);

    final continueButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
      },
      child: const Text('Continue'),
    );
    final adBanner;
    if (adsControllerAvailable && !adsRemoved) {
      adBanner = const Expanded(
        child: Center(
          child: BannerAdWidget(),
        ),
      );
    } else {
      adBanner = null;
    }
    final congratulationText = const Center(
      child: Text(
        'You won!',
        style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 50),
      ),
    );
    final scoreText = Center(
      child: Text(
        'Score: ${score.value}\n'
            'Time: ${score.formattedTime}',
        style: const TextStyle(
            fontFamily: 'Permanent Marker', fontSize: 20),
      ),
    );
    final winGameArea = ResponsiveScreen(
      squarishMainArea: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (adsControllerAvailable && !adsRemoved) ...[
            adBanner,
          ],
          gap,
          congratulationText,
          gap,
          scoreText,
        ],
      ),
      rectangularMenuArea: continueButton,
    );

    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: winGameArea,
    );
  }
}
