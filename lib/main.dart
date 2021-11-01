import 'dart:async';

import 'package:bytebank/components/container.dart';
import 'package:bytebank/components/theme.dart';
import 'package:bytebank/screens/counter.dart';
import 'package:bytebank/screens/name.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'components/localization.dart';
import 'screens/dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class LogObserver extends BlocObserver {
  @override
  void onChange(BlocBase cubit, Change change) {
    print("${cubit.runtimeType} > $change");
    super.onChange(cubit, change);
  }
}

class BytebankApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // na pratica evitar log do genero, pois pde vazar informações
    Bloc.observer = LogObserver();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: bytebankTheme,
      home: LocalizationContainer(
        child: DashboardContainer(),
      ),
    );
  }
}

