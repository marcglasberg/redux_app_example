import "dart:async";
import "dart:io";

import 'package:async_redux/local_persist.dart';
import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/foundation.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////

typedef Json = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

////////////////////////////////////////////////////////////////////////////////////////////////////

class AppPersistor extends Persistor<AppState> {
  //
  static const dbName_Number = "number";
  static const dbName_descriptionCache = "descriptionCache";

  /// Read the saved state from the persistence. Should return null if the state is not yet
  /// persisted. This method should be called only once, the app starts, before the store is
  /// created. The state it returns may become the store's initial state. If some error
  /// occurs while loading the info, we have to deal with it, by fixing the problem. In the worse
  /// case, if we think the state is corrupted and cannot be fixed, one alternative is deleting
  /// all persisted files and returning null.
  @override
  Future<AppState?> readState() async {
    AppState? state;

    try {
      print('Reading state from disk.');
      state = await _readFromDisk();
    }
    //
    catch (error, stackTrace) {
      // We should log this error, but we should not throw it.
      print('\n'
          'Error while reading from the local persistence:\n'
          'Error: $error.'
          'StackTrace: $stackTrace.\n');
    }

    // If we managed to read the saved that, return it.
    // It will later become the store's initial state.
    if (state != null)
      return state;
    //
    // When an error happens, state is null.
    else {
      print('Creating an empty state.');

      // So, we delete the old corrupted state from disk.
      await deleteState();

      // And them recreate the empty state and save it to disk.
      AppState state = AppState.initialState();
      await saveInitialState(state);

      // The empty state will later become the store's initial state.
      return state;
    }
  }

  Future<AppState?> _readFromDisk() async {
    //
    /// We are reading in sequence, but the correct here is reading both in parallel,
    /// by using `Future.wait([...])`
    int number = await _readNumber() ?? -1;
    IMap<int, String> descriptionCache = await _readDescriptionCache();

    var state = AppState.initialState().copyWith(
      number: number,
      descriptionCache: descriptionCache,
    );

    print('Just read the state from disk: $state.');

    return state;
  }

  /// Here I demonstrate returning `null` if the file does not contain a valid number.
  /// This means it will NOT delete all the persistence if this read value is corrupted.
  /// The value will be fixed later, when we save the state next time.
  Future<int?> _readNumber() async {
    print('Reading $dbName_Number.db.');

    LocalPersist localPersist = LocalPersist(dbName_Number);
    List<Object?>? result = await localPersist.load();
    return (result == null) ||
            (result.length != 1) ||
            (result.single is! int) ||
            (result.single as int < 0)
        ? null
        : result.single as int;
  }

  /// Here I demonstrate throwing an exception if the file does not contain a valid map with
  /// the correct key/value types (int for the key, and String for the value).
  /// This means it will delete all the persistence if this read value is corrupted.
  Future<IMap<int, String>> _readDescriptionCache() async {
    print('Reading $dbName_descriptionCache.db.');

    LocalPersist localPersist = LocalPersist(dbName_descriptionCache);
    List<Object?>? result = await localPersist.load();

    if (result == null) return const IMapConst({});

    if ((result.length != 1) || (result.single is! Map)) throw AppError();

    // JSON keys are be strings, by definition, but our map needs int keys.
    var mapOfStringString = result.single as Map<String, dynamic>;
    return mapOfStringString
        .map((String key, dynamic value) => MapEntry<int, String>(int.parse(key), value as String))
        .lock;
  }

  @override
  Future<void> deleteState() async {
    print('Deleting the state from disk.');
    var rootDir = await findRootDireForLocalPersist();
    if (rootDir.existsSync()) await rootDir.delete(recursive: true);
  }

  /// Return the directory `LocalPersist` saves the files and create subdirectories.
  @visibleForTesting
  Future<Directory> findRootDireForLocalPersist() async {
    // Hack to get the dir, since this info is not shared.
    var fileInRoot = await LocalPersist("file-in-root").file();
    return fileInRoot.parent;
  }

  @override
  Future<void> persistDifference({
    required AppState? lastPersistedState,
    required AppState newState,
  }) async {
    bool ifPersisted = false;

    // ---

    /// 1) We are saving in sequence, but the correct here is saving both in parallel,
    /// by using `Future.wait([...])`

    /// Here I compare the last saved number with the current number in the state.
    /// If the number changed, I save it to a file. I could have saved it to a database instead,
    /// or even to a cloud service.
    if (newState.number != lastPersistedState?.number) {
      print('Persisting the number to disk.');
      ifPersisted = true;

      LocalPersist localPersist = LocalPersist(dbName_Number);

      await localPersist.save([newState.number]);
    }

    // ---

    /// 2) Here I compare the last saved description cache with the current cache in the state.
    /// Note I can easily compare the maps, because I'm using an `IMap` (from the package
    /// https://pub.dev/packages/fast_immutable_collections), which compares by equality,
    /// not identity.
    ///
    /// If the cache changed, I save the new cache to a file. Note that, instead, I could have
    /// saved only the difference from the current cache to the previous one, by appending to
    /// the file. I could also have saved it to a database instead, or even to a cloud service.
    if (newState.descriptionCache != lastPersistedState?.descriptionCache) {
      print('Persisting the description cache to disk.');
      ifPersisted = true;

      LocalPersist localPersist = LocalPersist(dbName_descriptionCache);

      // JSON keys must be strings, by definition.
      IMap<String, String> map = newState.descriptionCache
          .map((int key, String value) => MapEntry<String, String>(key.toString(), value));

      // TODO: MARCELO Fix the IMap in FIC, so that it's directly serializable, without
      // TODO: having to unlock.
      await localPersist.save([map.unlock]);
    }

    if (!ifPersisted) print('It was not necessary to persist the state to disk.');
  }

  @override
  Future<void> saveInitialState(AppState state) =>
      persistDifference(lastPersistedState: null, newState: state);

  @override
  Duration get throttle => const Duration(seconds: 2);
}
