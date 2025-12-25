import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

mixin UserSetupMixin {
  final _repo = getIt<BaseAppRepository>();

  Future<UserSetup?> userSetup() async {
    return await _repo.getUserSetup().then((r) {
      return r.fold((f) => null, (userSetup) => userSetup);
    });
  }
}
