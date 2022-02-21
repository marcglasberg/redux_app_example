import "dart:async";

import 'package:async_redux_project_template/_EXPORT.dart';
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

Future<void> startApp(RunConfig runConfig) async {
  //
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Business.init(runConfig), // Business classes, immutable state classes, AsyncRedux/Actions.
    Client.init(), // Flutter widgets and screens.
  ]);

  runApp(const AppHomePage());
}
