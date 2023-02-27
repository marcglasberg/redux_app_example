import 'package:async_redux_project_template/_EXPORT.dart';

class SearchTrivia_Action extends AppAction {
  //
  final int? number;

  SearchTrivia_Action(this.number);

  SearchTrivia_Action.from(String number) : number = _parse(number);

  static int? _parse(String number) => int.tryParse(number);

  @override
  AppState? reduce() {
    //
    int? number = this.number;
    if (number == null) throw const UserException('Please, type a valid number.');
    if (number < 0) throw const UserException('Please, type a positive number.');

    dispatch(LoadNumberDescription_Action(number));

    return state.copyWith(number: number);
  }
}
