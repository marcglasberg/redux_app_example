import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/foundation.dart';

class Business {
  static late Store<AppState> store;

  static Future<void> init(RunConfig runConfig) async {
    //
    // Set the RunConfig instance.
    RunConfig.setInstance(runConfig);

    // Create the persistor, and try to read any previously saved state.
    var persistor = AppPersistor();
    AppState? initialState = await persistor.readState();

    // 4) If there is no saved state, create a new empty one and save it.
    if (initialState == null) {
      initialState = AppState.initialState();
      await persistor.saveInitialState(initialState);
    }

    // Create the store.
    store = Store<AppState>(
      initialState: initialState,
      persistor: persistor,
      wrapError: AppWrapError(),
      wrapReduce: AppWrapReduce(),
      actionObservers: kReleaseMode ? null : [ConsoleActionObserver()],
    );

    // Initialize the DAO, if necessary.
    await DAO.init();

    // TODO: Dispatch an action to do stuff that needs to be done as soon as we open
    // TODO: the app, like reading info from the backend, opening websockets, etc.
    // store.dispatch(InitApp_Action());
  }
}

/// This will be useful soon to unwrap errors thrown by the backend.
class AppWrapError<St> extends WrapError<St> {
  //
  @override
  Object? wrap(Object error, [StackTrace? stackTrace, ReduxAction<St>? action]) {
    return error;
  }
}

/// Not doing anything at the moment.
class AppWrapReduce extends WrapReduce<AppState> {
  //
  @override
  bool ifShouldProcess() => false;

  @override
  AppState process({
    required AppState oldState,
    required AppState newState,
  }) {
    return newState;
  }
}
