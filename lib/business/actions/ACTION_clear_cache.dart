import 'package:async_redux_project_template/_EXPORT.dart';

class ClearCache_Action extends AppAction {
  //
  @override
  Future<AppState?> reduce() async {
    return state.copyWith(
      descriptionCache: state.descriptionCache.clear(),
    );
  }
}
