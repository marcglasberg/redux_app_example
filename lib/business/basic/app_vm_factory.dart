import 'package:async_redux_project_template/_EXPORT.dart';
import "package:flutter/widgets.dart";

abstract class AppVmFactory<Model extends Vm, T extends Widget?>
    extends VmFactory<AppState, T, Model> {
  AppVmFactory([Widget? connector]) : super(connector as T?);

  @override
  T get widget {
    T? _connector = super.connector;
    if (_connector == null)
      throw AssertionError("Should pass the connector widget to your VmFactory constructor: "
          "`vm: () => _Factory(this)`"
          " and "
          "`_Factory($T? connector) : super(connector);`");
    return _connector;
  }
}
