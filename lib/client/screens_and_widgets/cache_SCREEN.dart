import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////

class Cache_Screen extends StatelessWidget with Screen {
  //
  const Cache_Screen();

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Vm>(
        vm: () => _Factory(),
        builder: (context, vm) {
          return Cache_Widget(
            descriptions: vm.descriptions,
            onClearCache: vm.onClearCache,
            onBack: vm.onBack,
            onTapCacheItem: vm.onTapCacheItem,
          );
        },
      );
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _Factory extends AppVmFactory {
  @override
  _Vm fromStore() => _Vm(
        //
        descriptions: state.descriptionCache,
        //
        onClearCache: () => dispatch(ClearCache_Action()),
        //
        onBack: () => dispatch(Navigate_Action.pop()),
        //
        onTapCacheItem: (int number) {
          dispatch(SearchTrivia_Action(number));
          dispatch(Navigate_Action.pop());
        },
      );
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _Vm extends Vm {
  //
  final IMap<int, String> descriptions;
  final VoidCallback onClearCache;
  final VoidCallback onBack;
  final ValueSetter<int> onTapCacheItem;

  _Vm({
    required this.descriptions,
    required this.onClearCache,
    required this.onBack,
    required this.onTapCacheItem,
  }) : super(equals: [descriptions]);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
