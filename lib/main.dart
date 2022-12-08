import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'game/game.dart';
import 'package:squish_them_all/game/overlays/game_over.dart';
import 'package:squish_them_all/game/overlays/main_menu.dart';
import 'package:squish_them_all/game/overlays/pause_menu.dart';
import 'package:squish_them_all/game/overlays/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// Import the firebase_app_check plugin
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    androidProvider: AndroidProvider.debug,
  );

  // await FirebaseAnalytics.instance.logBeginCheckout(
  //     value: 10.0,
  //     currency: 'USD',
  //     items: [
  //       AnalyticsEventItem(itemName: 'Socks', itemId: 'xjw73ndnw', price: 10.0),
  //     ],
  //     coupon: '10PERCENTOFF');

  // FlutterError.onError = (errorDetails) {
  //     FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  //   };
  //   // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  //   PlatformDispatcher.instance.onError = (error, stack) {
  //     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //     return true;
  //   };

  runApp(MyApp());
}

final _game = SquishThemAll();

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Squish Them All!',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: GameWidget<SquishThemAll>(
          game: kDebugMode ? SquishThemAll() : _game,
          overlayBuilderMap: {
            MainMenu.id: (context, game) => MainMenu(gameRef: game),
            PauseMenu.id: (context, game) => PauseMenu(gameRef: game),
            GameOver.id: (context, game) => GameOver(gameRef: game),
            Settings.id: (context, game) => Settings(gameRef: game),
          },
          initialActiveOverlays: const [MainMenu.id],
        ),
      ),
    );
  }
}
