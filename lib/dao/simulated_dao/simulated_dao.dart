import 'package:async_redux_project_template/_EXPORT.dart';
import 'get_initial_app_info.dart';

class SimulatedDao extends Dao with GetInitialAppInfo {
//
  static SimulatedDao get instance => RunConfig.instance.dao as SimulatedDao;

  SimulatedDao();

  @override
  Future<void> init() async {
    await SimBackend.init();
  }
}
