import 'package:salesforce/core/constants/constants.dart';

class ServerException implements Exception {
  final dynamic message;

  ServerException(this.message) {
    if (kAppScaffoldMsgKey.currentState != null) {
      // Helpers.showMessage(msg: message, status: MessageStatus.errors);
      // Logger.log(message.toString());
    }
  }
}

class NetworkException implements Exception {}

class GeneralException implements Exception {
  final dynamic message;

  GeneralException(this.message) {
    if (kAppScaffoldMsgKey.currentState != null) {
      // Logger.log(message.toString());
    }
  }

  @override
  String toString() {
    return "Exception: $message";
  }
}
