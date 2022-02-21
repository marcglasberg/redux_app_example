import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:async_redux_project_template/dao/simulated_dao/get_initial_app_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// We set up the [RunConfig] for the tests to achieve the following:
///
/// 1) We point [RunConfig.dao] to [SimulatedDao], because we want the tests
/// to run with the simulated backend, not the [RealDao]. This will speed up
/// running the tests.
///
/// 2) We make [RunConfig.ifChecksInternetConnection] false, because we do not
/// want to check the internet connection.
///
/// 3) We make [RunConfig.disablePlatformChannels] false. This will disable
/// platform channels, and it will also speed up running the tests, by
/// disabling fake delays in the function [simulatesWaiting], which is used
/// in the simulation; for example in [GetInitialAppInfo.loadNumberDescription].
///
void main() {
  setUp(() async {
    //
    RunConfig.setInstance(
      RunConfig(
        dao: SimulatedDao(),
        ifChecksInternetConnection: false,
        disablePlatformChannels: false,
      ),
    );

    await DAO.init();
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test('Loading number description.', () async {
    //
    var store = Store<AppState>(initialState: AppState.initialState());
    var storeTester = StoreTester.from(store);

    // ---

    // Let's load number 5.
    var action = LoadNumberDescription_Action(5);
    storeTester.dispatch(action);
    await storeTester.waitUntilAction(action);

    // Note, another way of waiting for the action to finish is this:
    // `await storeTester.waitCondition((info) => info.state.descriptionCache.isNotEmpty);`

    expect(
        storeTester.lastInfo.state.descriptionCache,
        {
          5: 'This is a simulated description for number 5!',
        }.lock);

    // ---

    // Now, let's load number 20.
    action = LoadNumberDescription_Action(20);
    storeTester.dispatch(action);
    await storeTester.waitUntilAction(action);

    expect(
        storeTester.lastInfo.state.descriptionCache,
        {
          5: 'This is a simulated description for number 5!',
          20: 'This is a simulated description for number 20!',
        }.lock);
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////
}
