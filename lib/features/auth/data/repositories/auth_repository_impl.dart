import 'package:dartz/dartz.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/data/models/extension/login_session_extension.dart';
import 'package:salesforce/core/data/models/extension/user_setup_extenstion.dart';
import 'package:salesforce/core/data/repositories/base_app_repository_impl.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/features/auth/domain/entities/notification_model.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/features/auth/data/datasources/api/api_auth_data_source.dart';
import 'package:salesforce/features/auth/data/datasources/realm/realm_auth_data_source.dart';
import 'package:salesforce/features/auth/domain/entities/login_arg.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class AuthRepositoryImpl extends BaseAppRepositoryImpl
    implements AuthRepository {
  final ApiAuthDataSource _remote;
  final RealmAuthDataSource _local;
  final NetworkInfo _networkInfo;

  const AuthRepositoryImpl({
    required ApiAuthDataSource super.remote,
    required RealmAuthDataSource super.local,
    required super.networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<AppServer>>> getServerLists() async {
    try {
      List<AppServer> localServers = await _local.getServerLists();

      if (await _networkInfo.isConnected) {
        final servers = await _remote.getServerLists();
        _local.storeServers(servers);

        return Right(servers);
      }

      if (localServers.isEmpty && !await _networkInfo.isConnected) {
        return const Left(CacheFailure(errorInternetMessage));
      }

      return Right(localServers);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      if (!await _networkInfo.isConnected) {
        throw GeneralException(errorInternetMessage);
      }
      _remote.logout();

      LoginSession? user = await _local.getLoginSession();

      if (user == null) {
        return true;
      }

      await _local.logout();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> login({required LoginArg arg}) async {
    if (!await _networkInfo.isConnected) {
      throw GeneralException(errorInternetMessage);
    }

    await _handleOnlineLogin(arg);
  }

  Future<void> _handleOnlineLogin(LoginArg arg) async {
    try {
      final result = await _remote.login(arg: arg);

      final userLogin = LoginSessionExtension.fromMap(result);

      setAuthInjection(userLogin);

      await _local.storeAppSetting([
        AppSetting(kUserId, userLogin.id),
        AppSetting(kConnectionKey, arg.server.id),
      ]);

      await _local.storeLoginSession(userLogin);
      await _local.storeUserSetup(UserSetupExtension.fromMap(result));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, NotificationArg>> getNotification({Map? arg}) async {
    try {
      if (await _networkInfo.isConnected) {
        final record = await _remote.getNotification(arg: arg);
        final List<NotificationModel> notifications = [];
        for (var data in record["records"]) {
          notifications.add(NotificationModel.fromJson(data));
        }

        return Right(
          NotificationArg(
            notifications: notifications,
            countNotification: record["count"],
          ),
        );
      }
      return Left(CacheFailure(errorInternetMessage));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> offlineLogin({
    required String username,
    required String token,
  }) async {
    try {
      final auth = await _local.login(username, token);
      setAuthInjection(auth);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyResetPassword({
    Map? arg,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw GeneralException(errorInternetMessage);
    }
    final record = await _remote.verifyResetPassword(arg: arg);
    try {
      if (record["status"] != "success") {
        return Left(CacheFailure(record["message"]));
      }
      return Right(record);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }
}
