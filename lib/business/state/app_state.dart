import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';

@immutable
class AppState {
  //
  final Wait wait;

  final int number; // -1 means we have no number.

  final IMap<int, String> descriptionCache;

  AppState({
    required this.wait,
    required this.number,
    required this.descriptionCache,
  });

  static AppState initialState() {
    return AppState(
      wait: Wait.empty,
      number: -1,
      descriptionCache: const IMapConst({}),
    );
  }

  AppState copyWith({
    Wait? wait,
    int? number,
    IMap<int, String>? descriptionCache,
  }) {
    return AppState(
      wait: wait ?? this.wait,
      number: number ?? this.number,
      descriptionCache: descriptionCache ?? this.descriptionCache,
    );
  }

  @override
  String toString() => 'AppState{\n'
      '  number: $number,\n'
      '  descriptionCache: $descriptionCache'
      '\n}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          wait == other.wait &&
          number == other.number &&
          descriptionCache == other.descriptionCache;

  @override
  int get hashCode => wait.hashCode ^ number.hashCode ^ descriptionCache.hashCode;
}
