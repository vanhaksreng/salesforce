import 'package:salesforce/core/data/datasources/realm/base_realm_data_source_impl.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/features/auth/data/datasources/realm/realm_auth_data_source.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class RealmAuthDataSourceImpl extends BaseRealmDataSourceImpl implements RealmAuthDataSource {
  final ILocalStorage _storage;

  RealmAuthDataSourceImpl({required super.ils}) : _storage = ils;

  @override
  Future<List<AppServer>> getServerLists() async {
    return await _storage.getAll<AppServer>();
  }

  @override
  Future<void> storeServers(List<AppServer> servers) async {
    _storage.writeTransaction((realm) {
      realm.deleteMany(realm.all<AppServer>().toList());

      realm.addAll(servers);
      return "success";
    });
  }

  @override
  Future<LoginSession> login(String email, String token) async {
    final auth = await _storage.getFirst<LoginSession>(args: {"email": email, "access_token": token});

    if (auth == null) {
      throw GeneralException("Login failed");
    }

    await _storage.writeTransaction((realm) {
      auth.isLogin = "Yes";
      realm.add(auth, update: true);
      return auth;
    });

    return auth;
  }

  @override
  Future<void> logout() async {
    try {
      final auth = await _storage.getFirst<LoginSession>();

      if (auth != null) {
        await _storage.writeTransaction((realm) {
          auth.isLogin = "No";

          realm.add(auth, update: true);

          return "success";
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> storeLoginSession(LoginSession user) async {
    _storage.writeTransaction((realm) {
      realm.deleteMany(realm.all<LoginSession>().toList());

      realm.add(user);
    });

    // LoginSession? existing = await _storage.getFirst<LoginSession>();
    // if (existing != null) {
    //   await _storage.update(user);
    // } else {
    //   await _storage.add(user);
    // }
  }
}
