import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FirebaseCrashlytics.instance
        .setUserIdentifier('alura123'); // passar id unico do usuario

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

// previne o flutter com erros do dart
  runZonedGuarded<Future<void>>(() async { 
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // The following lines are the same as previously explained in "Handling uncaught errors"
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(BytebankApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));

  runApp(BytebankApp());
  // findAll().then((transactions) => print('new transactions $transactions'));
}

class BytebankApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //remove canto superior a flag de debug
      theme: ThemeData(
          primaryColor: Colors.green[900],
          accentColor: Colors.blueAccent[700],
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blueAccent[700],
            textTheme: ButtonTextTheme.primary,
          )),
      home: DashBoard(),
    );
  }
}
