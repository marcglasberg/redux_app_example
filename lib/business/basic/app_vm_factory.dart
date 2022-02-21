import 'package:async_redux_project_template/_EXPORT.dart';
import "package:flutter/widgets.dart";

abstract class AppVmFactory<T extends Widget> extends VmFactory<AppState, T> {
  AppVmFactory([T? widget]) : super(widget);

  @override
  T get widget {
    T? _widget = super.widget;
    if (_widget == null)
      throw AssertionError("Should pass the widget to your VmFactory constructor: "
          "`vm: () => _Factory(this)`"
          " and "
          "`_Factory($T? widget) : super(widget);`");
    return _widget;
  }
}
