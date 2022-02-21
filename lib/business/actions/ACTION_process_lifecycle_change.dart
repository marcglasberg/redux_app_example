import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';

class ProcessLifecycleChange_Action extends AppAction {
  //
  final AppLifecycleState lifecycle;

  ProcessLifecycleChange_Action(this.lifecycle);

  @override
  Future<AppState?> reduce() async {
    //
    if (lifecycle == AppLifecycleState.resumed) {
      // TODO: Do stuff that needs to be done when the app is resumed.
      // await dispatch(OpenWebSocket_Action());

    }
    //
    else if (lifecycle == AppLifecycleState.inactive ||
        lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.detached) {
      // TODO: Do stuff that needs to be done when the app is inactive, paused and detached.
      // dispatch(CloseWebSocket_Action());
    }
    //
    else
      throw AssertionError(lifecycle);

    return null;
  }
}
