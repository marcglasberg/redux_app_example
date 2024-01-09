import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bdd_loading_description_test.dart' as bdd_loading_description_test;

void main() async {
  BddReporter.set(
    // Print the result to the console.
    ConsoleReporter(),

    // Create feature files.
    FeatureFileReporter(clearAllOutputBeforeRun: true),
  );

  group('bdd_loading_description_test.dart', bdd_loading_description_test.main);

  await BddReporter.reportAll();
}
