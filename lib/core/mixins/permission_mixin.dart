import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/injection_container.dart';

mixin PermissionMixin {
  final _repo = getIt<BaseAppRepository>();

  Future<bool> hasPermission(String name) async {
    return await _repo.hasPermission(name);
  }
}
