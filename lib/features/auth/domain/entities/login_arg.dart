import 'package:salesforce/realm/scheme/schemas.dart';

class LoginArg {
  final String email;
  final String password;
  final AppServer server;
  final String notificationKey;
  final String source;

  const LoginArg({
    required this.email,
    required this.password,
    required this.server,
    required this.notificationKey,
    this.source = "onesignal",
  });

  Map<String, dynamic> toJson() {
    return {'username': email, 'password': password, 'notification_token': notificationKey, 'source': source};
  }
}
