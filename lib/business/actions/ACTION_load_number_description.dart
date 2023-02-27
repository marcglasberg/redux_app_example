import 'package:async_redux_project_template/_EXPORT.dart';

/// Given a number, this will load a description and save that to the state,
/// in a map called [descriptionCache].
///
/// Note:
/// If we're using the real DAO, this will connect to the NumbersApi service.
/// If we're using the simulated DAO, this will use an in-memory fake service.
///
/// Note: In the [before] method we first check if there is an internet connection.
/// If there is not, we'll show an error dialog and abort loading.
///
class LoadNumberDescription_Action extends AppAction {
  //
  final int number;

  LoadNumberDescription_Action(this.number);

  @override
  Future<void> before() async {
    dispatch(WaitAction.add(this));
    await makeSureThereIsInternetConnection();
  }

  @override
  void after() => dispatch(WaitAction.remove(this));

  @override
  Future<AppState?> reduce() async {
    //
    /// If we already have cached the description for the given number,
    /// there is no need to download it again.
    if (state.descriptionCache.containsKey(number))
      return null;
    //
    else {
      /// Given a number, returns a description.
      /// Throws an error if the description cannot be found, or there is a connection error.
      Numbers_RESPONSE response = await DAO.loadNumberDescription(number: number);

      String description = response.description;

      return state.copyWith(
        descriptionCache: state.descriptionCache.add(number, description),
      );
    }
  }

  /// If the DAO.loadNumberDescription() method in [reduce] throws an error,
  /// we'll wrap that error here as a UserException. This will present a dialog to
  /// the user, explaining the problem.
  @override
  Object? wrapError(error, StackTrace stackTrace) {
    //
    String? errorMsg = (error is DaoGeneralError) ? error.msg : null;

    if (errorMsg == null)
      return UserException("Something went wrong while searching for $number.");
    else
      return UserException("Something went wrong:\n\n$errorMsg");
  }
}
