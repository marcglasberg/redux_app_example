import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Client {
  //
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Observes pushes and pops from a route.
  /// The observed route may be registered with `routeObserver.subscribe()`,
  /// while `routeObserver.unsubscribe()` cancels the registry.
  /// This is used in `PopAwareMixin` to detect when pop is done in the closest route in the tree.
  static final routeObserver = RouteObserver<PageRoute>();

  /// Allows Actions to navigate screens and tabs.
  static Future<void> init() async {
    //
    initNavigationCapabilities();

    // Makes sure error StackTraces are printed complete in the Console.
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details, forceReport: true);
    };

    // Allows only portrait orientation (for now). Forbids landscape.
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  static void initNavigationCapabilities() {
    //
    Navigate_Action.init(
      //
      navigatorKey: navigatorKey,
      //
      closeKeyboardFunc: () {
        /// How to Dismiss the Keyboard in Flutter the Right Way.
        /// https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
    );
  }
}
