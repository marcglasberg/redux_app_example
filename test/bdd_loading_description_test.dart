import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';

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

  var feature = BddFeature('Loading description');

  Bdd(feature)
      .scenario('Loading the description of a number.')
      .given('There are no descriptions cached.')
      .when('We load the description for number 5.')
      .then('The description of number 5 is loaded and cached.')
      .run((ctx) async {
    //
    var store = Store<AppState>(initialState: AppState.initialState());
    var storeTester = StoreTester.from(store);

    // Given: There are no descriptions cached.
    expect(store.state.descriptionCache, isEmpty);

    // When: We load the description for number 5.
    var action = LoadNumberDescription_Action(5);
    storeTester.dispatch(action);
    await storeTester.waitUntilAction(action);

    // Then: The description of number 5 is loaded and cached.
    expect(
        storeTester.lastInfo.state.descriptionCache,
        {
          5: 'This is a simulated description for number 5!',
        }.lock);
  });

  Bdd(feature)
      .scenario('Loading the description of two numbers.')
      .given('There are no descriptions cached.')
      .when('We load the description for number 20, and then for number 5.')
      .then('The descriptions of numbers 5 and 20 are loaded and cached.')
      .run((ctx) async {
    //
    var store = Store<AppState>(initialState: AppState.initialState());
    var storeTester = StoreTester.from(store);

    // Given: There are no descriptions cached.
    expect(store.state.descriptionCache, isEmpty);

    // When: We load the description for number 20, and then for number 5.
    var action = LoadNumberDescription_Action(20);
    storeTester.dispatch(action);
    await storeTester.waitUntilAction(action);

    action = LoadNumberDescription_Action(5);
    storeTester.dispatch(action);
    await storeTester.waitUntilAction(action);

    // Then: The descriptions of numbers 5 and 20 are loaded and cached.
    expect(
        storeTester.lastInfo.state.descriptionCache,
        {
          5: 'This is a simulated description for number 5!',
          20: 'This is a simulated description for number 20!',
        }.lock);
  });

  Bdd(feature)
      .scenario('Clearing the cache of descriptions.')
      .given('There are descriptions cached.')
      .when('We clear the cache.')
      .then('The cache is empty.')
      .run((ctx) async {
    //
    var store = Store<AppState>(
        initialState: AppState.initialState().copyWith(
      descriptionCache: const IMapConst({
        5: 'This is a simulated description for number 5!',
        20: 'This is a simulated description for number 20!',
      }),
    ));
    var storeTester = StoreTester.from(store);

    // Given: There is a description cached.
    expect(store.state.descriptionCache, isNotEmpty);

    // When: We clear the cache.
    var action = ClearCache_Action();
    storeTester.dispatch(action);
    await storeTester.waitUntilAction(action);

    // Then: The cache is empty.
    expect(storeTester.lastInfo.state.descriptionCache, isEmpty);
  });
}
