import "dart:async";

import 'package:async_redux_project_template/_EXPORT.dart';
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

Future<void> startApp(RunConfig runConfig) async {
  //
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiates the Business and the Client layers.
  await Future.wait([
    Business.init(runConfig), // Business layer, like state classes, AsyncRedux/Actions.
    Client.init(), // Client layer, like Flutter widgets and screens.
  ]);

  runApp(const AppHomePage());
}
