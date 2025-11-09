import 'package:dartz/dartz.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/features/auth/domain/entities/login_arg.dart';
import 'package:salesforce/features/auth/domain/entities/notification_model.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

abstract class AuthRepository extends BaseAppRepository {
  Future<void> login({required LoginArg arg});

  Future<bool> offlineLogin({required String username, required String token});

  Future<bool> logout();

  Future<Either<Failure, List<AppServer>>> getServerLists();
  Future<Either<Failure, NotificationArg>> getNotification({Map? arg});
  Future<Either<Failure, Map<String, dynamic>>> verifyResetPassword({Map? arg});
}
