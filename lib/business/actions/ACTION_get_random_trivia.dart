import 'dart:math';

import 'package:async_redux_project_template/_EXPORT.dart';

class GetRandomTrivia_Action extends AppAction {
  //
  static Random random = Random();
  static int maxNumber = 100;

  @override
  AppState? reduce() {
    int number = random.nextInt(maxNumber);
    dispatch(SearchTrivia_Action(number));

    return null;
  }
}
