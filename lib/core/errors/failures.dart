import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';

abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  late String _message = "";

  NetworkFailure(String message) : super(message) {
    if (kAppScaffoldMsgKey.currentState != null) {
      Helpers.showMessage(msg: message, status: MessageStatus.errors);
      _message = message;
    }
  }

  @override
  String toString() {
    return _message;
  }
}
