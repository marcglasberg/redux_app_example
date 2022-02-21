import 'package:async_redux_project_template/_EXPORT.dart';

void main() async {
  //

  /// A run-configuration let's us change some of the app characteristics at compile time.
  /// We can have multiple main methods with different run-configurations, or we can create
  /// the run-configuration programmatically.
  var runConfig = RunConfig(
    //
    /// If we inject the REAL dao, it will connect to the real backend service.
    /// If we inject the SIMULATED dao, it will simulate the backend service.
    dao: RealDao(),
    // dao: SimulatedDao(), // Another option.
    //
  );

  startApp(runConfig);
}
