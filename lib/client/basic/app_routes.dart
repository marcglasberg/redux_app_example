import 'package:async_redux_project_template/_EXPORT.dart';
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

////////////////////////////////////////////////////////////////////////////////////////////////////

class AppRoutes {
  //
  static Route onGenerateRoute(RouteSettings settings) {
    return AppRoutes(settings)._generate();
  }

  final RouteSettings settings;

  AppRoutes(this.settings);

  Route _generate() {
    //
    // TODO: REMOVE
    // List<String> args = settings.name!.split("/");
    // String nome = args[0];
    // args.removeAt(0);

    if (settings.name == '/') {
      return NoAnimationRoute(firstScreen());
    }
    //
    else {
      throw NotYetImplementedError();
    }
  }

  static Screen firstScreen() {
    /// This would be extended in a real app, to return different first screens depending on
    /// the situation. For example, if the user is not logged in, this could return a login
    /// screen instead.
    return const Trivia_Screen();
  }
}

/// If the route is from this screen, return true.
/// The route should start with the [Screen] class name (without the "_Screen" suffix),
/// followed by arguments separated by '/'.
///
/// For example: "MyUser/mark" may start screen `MyUser_Screen(user: 'mark')`
bool ifScreen(String name, Type ScreenRuntimeType) {
  return "${name}_Screen" == ScreenRuntimeType.toString();
}

Type getReturnType<T extends Type>(T Function(List<String>) method) => T;
