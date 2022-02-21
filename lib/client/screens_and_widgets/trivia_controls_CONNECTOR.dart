import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';

import 'trivia_controls_widget.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////

class TriviaControls_Connector extends StatelessWidget {
  //
  const TriviaControls_Connector();

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Vm>(
        vm: () => _Factory(),
        builder: (context, vm) {
          return TriviaControls(
            onGetRandomTrivia: vm.onGetRandomTrivia,
            onSearchTrivia: vm.onSearchTrivia,
          );
        },
      );
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _Factory extends AppVmFactory {
  @override
  _Vm fromStore() => _Vm(
        //
        onGetRandomTrivia: () => dispatch(GetRandomTrivia_Action()),
        //
        onSearchTrivia: (String number) => dispatch(SearchTrivia_Action.from(number)),
      );
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _Vm extends Vm {
  //
  final VoidCallback onGetRandomTrivia;
  final ValueSetter<String> onSearchTrivia;

  _Vm({
    required this.onGetRandomTrivia,
    required this.onSearchTrivia,
  }) : super(equals: []);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
