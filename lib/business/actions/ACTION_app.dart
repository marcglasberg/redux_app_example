import 'package:async_redux_project_template/_EXPORT.dart';

abstract class AppAction extends ReduxAction<AppState> {
  @override
  String toString() => runtimeType.toString();
}
