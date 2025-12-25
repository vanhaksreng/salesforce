import 'package:salesforce/core/data/datasources/realm/base_realm_data_source.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

abstract class RealmAuthDataSource extends BaseRealmDataSource {
  Future<LoginSession?> login(String email, String token);
  Future<void> logout();

  Future<void> storeLoginSession(LoginSession user);

  Future<void> storeServers(List<AppServer> servers);
  Future<List<AppServer>> getServerLists();
}
