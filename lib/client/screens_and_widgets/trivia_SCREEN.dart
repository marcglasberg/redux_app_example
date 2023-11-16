import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';

class Trivia_Screen extends StatelessWidget with Screen {
  //
  const Trivia_Screen();

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Vm>(
        vm: () => _Factory(),
        builder: (context, vm) {
          return Trivia_Widget(
            wait: vm.wait,
            number: vm.number,
            description: vm.description,
            onSeeCache: vm.onSeeCache,
          );
        },
      );
}

class _Factory extends AppVmFactory {
  @override
  _Vm fromStore() {
    //
    int number = state.number;

    return _Vm(
      wait: state.wait,
      number: number,
      description: state.descriptionCache[number] ?? '',
      onSeeCache: () => dispatch(Navigate_Action.push(const Cache_Screen())),
    );
  }
}

class _Vm extends Vm {
  //
  final Wait wait;
  final int number;
  final String description;
  final VoidCallback onSeeCache;

  _Vm({
    required this.wait,
    required this.number,
    required this.description,
    required this.onSeeCache,
  }) : super(equals: [
          wait,
          number,
          description,
        ]);
}
