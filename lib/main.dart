// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/main_menu/persistent_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'src/ads/ads_controller.dart';
import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/audio/audio_controller.dart';
import 'src/crashlytics/crashlytics.dart';
import 'src/games_services/games_services.dart';
import 'src/games_services/score.dart';
import 'src/in_app_purchase/in_app_purchase.dart';
import 'src/main_menu/main_menu_screen.dart';
import 'src/play_session/play_session_screen.dart';
import 'src/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'src/player_progress/persistence/player_progress_persistence.dart';
import 'src/player_progress/player_progress.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';
import 'src/settings/persistence/settings_persistence.dart';
import 'src/settings/settings.dart';
import 'src/settings/settings_screen.dart';
import 'src/style/my_transition.dart';
import 'src/style/palette.dart';
import 'src/style/snack_bar.dart';
import 'src/win_game/win_game_screen.dart';

Future<void> main() async {
  // Uncomment the following lines to enable Firebase Crashlytics.
  // See lib/src/crashlytics/README.md for details.

  FirebaseCrashlytics? crashlytics;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   try {
  //     WidgetsFlutterBinding.ensureInitialized();
  //     await Firebase.initializeApp(
  //       options: DefaultFirebaseOptions.currentPlatform,
  //     );
  //     crashlytics = FirebaseCrashlytics.instance;
  //   } catch (e) {
  //     debugPrint("Firebase couldn't be initialized: $e");
  //   }
  // }

  await guardWithCrashlytics(
    guardedMain,
    crashlytics: crashlytics,
  );
}

/// Without logging and crash reporting, this would be `void main()`.
void guardedMain() {
  if (kReleaseMode) {
    // Don't log anything below warnings in production.
    Logger.root.level = Level.WARNING;
  }
  Logger.root.onRecord.listen((record) {
    // debugPrint('${record.level.name}: ${record.time}: '
    //     '${record.loggerName}: '
    //     '${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  _log.info('Going full screen');
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // TODO: When ready, uncomment the following lines to enable integrations.
  //       Read the README for more info on each integration.

  AdsController? adsController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   /// Prepare the google_mobile_ads plugin so that the first ad loads
  //   /// faster. This can be done later or with a delay if startup
  //   /// experience suffers.
  //   adsController = AdsController(MobileAds.instance);
  //   adsController.initialize();
  // }

  GamesServicesController? gamesServicesController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   gamesServicesController = GamesServicesController()
  //     // Attempt to log the player in.
  //     ..initialize();
  // }

  InAppPurchaseController? inAppPurchaseController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   inAppPurchaseController = InAppPurchaseController(InAppPurchase.instance)
  //     // Subscribing to [InAppPurchase.instance.purchaseStream] as soon
  //     // as possible in order not to miss any updates.
  //     ..subscribe();
  //   // Ask the store what the player has bought already.
  //   inAppPurchaseController.restorePurchases();
  // }

  runApp(
    MyApp(
      settingsPersistence: LocalStorageSettingsPersistence(),
      playerProgressPersistence: LocalStoragePlayerProgressPersistence(),
      inAppPurchaseController: inAppPurchaseController,
      adsController: adsController,
      gamesServicesController: gamesServicesController,
    ),
  );
}

Logger _log = Logger('main.dart');

class MyApp extends StatelessWidget {
  static final _log = Logger('Main');

  static final victoryRoute = GoRoute(
    path: 'won',
    pageBuilder: (context, state) {
      final map = state.extra! as Map<String, dynamic>;
      final score = map['score'] as Score;

      return buildMyTransition(
        child: WinGameScreen(
          score: score,
          key: const Key('win game'),
        ),
        color: context.watch<Palette>().backgroundPlaySession,
      );
    },
  );

  static final playRoute = GoRoute(
      path: 'play',
      pageBuilder: (context, state) => buildMyTransition(
            child: PlaySessionScreen(
              key: const Key('play session'),
            ),
            color: context.watch<Palette>().backgroundPlaySession,
          ),
      routes: [
        victoryRoute,
      ]);

  static final settingsRoute = GoRoute(
    path: 'settings',
    builder: (context, state) => const SettingsScreen(key: Key('settings')),
  );

  static final mainMenuRoute = GoRoute(
      path: '/',
      builder: (context, state) {
        return const MainMenuScreen(key: Key('main menu'));
      },
      routes: [
        playRoute,
        settingsRoute,
      ]);

  static final _router = GoRouter(
    routes: [mainMenuRoute],
  );

  final PlayerProgressPersistence playerProgressPersistence;

  final SettingsPersistence settingsPersistence;

  final GamesServicesController? gamesServicesController;

  final InAppPurchaseController? inAppPurchaseController;

  final AdsController? adsController;

  const MyApp({
    required this.playerProgressPersistence,
    required this.settingsPersistence,
    required this.inAppPurchaseController,
    required this.adsController,
    required this.gamesServicesController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerProgressProvider = ChangeNotifierProvider(
      create: (context) {
        var progress = PlayerProgress(playerProgressPersistence);
        progress.getLatestFromStore().then((_) => _log.info(
            'Getting the highest player score from the storage: ${progress.highestScoreReached}'));
        return progress;
      },
    );
    final gamesServicesControllerProvider =
        Provider<GamesServicesController?>.value(
            value: gamesServicesController);
    final adsControllerProvider =
        Provider<AdsController?>.value(value: adsController);
    final inAppPurchaseControllerProvider =
        ChangeNotifierProvider<InAppPurchaseController?>.value(
            value: inAppPurchaseController);
    final settingsControllerProvider = Provider<SettingsController>(
      lazy: false,
      create: (context) => SettingsController(
        persistence: settingsPersistence,
      )..loadStateFromPersistence(),
    );
    final audioControllerProvider = ProxyProvider2<SettingsController,
        ValueNotifier<AppLifecycleState>, AudioController>(
      // Ensures that the AudioController is created on startup,
      // and not "only when it's needed", as is default behavior.
      // This way, music starts immediately.
      lazy: false,
      create: (context) => AudioController()..initialize(),
      update: (context, settings, lifecycleNotifier, audio) {
        if (audio == null) throw ArgumentError.notNull();
        audio.attachSettings(settings);
        audio.attachLifecycleNotifier(lifecycleNotifier);
        return audio;
      },
      dispose: (context, audio) => audio.dispose(),
    );
    final paletteProvider = Provider(
      create: (context) => Palette(),
    );

    final pageTheme = Builder(builder: (context) {
      final palette = context.watch<Palette>();
      return MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: palette.darkPen,
            background: palette.backgroundMain,
          ),
          textTheme: TextTheme(
            bodyText2: TextStyle(
              color: palette.ink,
            ),
          ),
        ),
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        scaffoldMessengerKey: scaffoldMessengerKey,
        builder: (context, state) {
          return BaseWidget(child: state!);
        },
      );
    });
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          playerProgressProvider,
          gamesServicesControllerProvider,
          adsControllerProvider,
          inAppPurchaseControllerProvider,
          settingsControllerProvider,
          audioControllerProvider,
          paletteProvider,
        ],
        child: pageTheme,
      ),
    );
  }
}
